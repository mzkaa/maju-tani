
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return json({ error: "Method tidak diizinkan" }, 405);
  }

  try {
    const url = Deno.env.get("SUPABASE_URL")!;
    const secretKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const publishableKey = Deno.env.get("SUPABASE_ANON_KEY");

    const secretKey =
      secretKeys.default ?? Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const publishableKey =
      publishableKeys.default ?? Deno.env.get("SUPABASE_ANON_KEY");

    if (!secretKey || !publishableKey) {
      return json({ error: "Konfigurasi Supabase belum lengkap" }, 500);
    }

    if (req.headers.get("apikey") !== publishableKey) {
      return json({ error: "API key tidak valid" }, 401);
    }

    const { username, password } = await req.json();

    const nama = String(username ?? "").trim().toLowerCase();
    const sandi = String(password ?? "");

    if (!/^[a-z0-9._-]{3,30}$/.test(nama)) {
      return json({
        error: "Username harus 3-30 karakter dan hanya menggunakan huruf, angka, titik, garis bawah, atau strip."
      }, 400);
    }

    if (sandi.length < 8) {
      return json({ error: "Kata sandi minimal 8 karakter" }, 400);
    }

    const admin = createClient(url, secretKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    // Pastikan hanya satu akun pemilik.
    const { data: pemilik, error: cekError } = await admin
      .from("owner_profiles")
      .select("id")
      .limit(1);

    if (cekError) throw cekError;

    if (pemilik && pemilik.length > 0) {
      return json({ error: "Akun pemilik sudah terdaftar" }, 409);
    }

    // Email internal untuk menghubungkan username dengan Supabase Auth.
    const email = `${nama}@owner.mitramajutani.invalid`;

    const { data: akun, error: authError } =
      await admin.auth.admin.createUser({
        email,
        password: sandi,
        email_confirm: true,
      });

    if (authError) {
      return json({ error: "Gagal membuat akun: " + authError.message }, 400);
    }

    // ID selalu 1: hanya satu profil pemilik.
    const { error: simpanError } = await admin
      .from("owner_profiles")
      .insert({
        id: 1,
        user_id: akun.user.id,
        username: nama,
      });

    if (simpanError) {
      await admin.auth.admin.deleteUser(akun.user.id);
      if (simpanError.code === "23505") {
        return json({ error: "Akun pemilik sudah terdaftar" }, 409);
      }
      throw simpanError;
    }

    return json({
      success: true,
      message: "Akun pemilik berhasil dibuat",
      username: nama,
    }, 201);

  } catch (error) {
    console.error(error);
    return json({ error: "Terjadi kesalahan pada server" }, 500);
  }
});
