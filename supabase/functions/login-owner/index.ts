
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return json({ error: "Method tidak diizinkan" }, 405);
  }

  try {
    const url = Deno.env.get("SUPABASE_URL")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!anonKey || !serviceKey) {
      return json({ error: "Konfigurasi server belum lengkap" }, 500);
    }

    const { username, password } = await req.json();

    const nama = String(username ?? "").trim().toLowerCase();
    const sandi = String(password ?? "");

    if (!/^[a-z0-9._-]{3,30}$/.test(nama) || !sandi) {
      return json({ error: "Username atau kata sandi salah" }, 401);
    }

    // Mencari akun pemilik menggunakan akses server.
    const admin = createClient(url, serviceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });

    const { data: profil, error: profilError } = await admin
      .from("owner_profiles")
      .select("username")
      .eq("username", nama)
      .maybeSingle();

    if (profilError) throw profilError;

    if (!profil) {
      return json({ error: "Username atau kata sandi salah" }, 401);
    }

    // Autentikasi menggunakan Supabase Auth.
    const authClient = createClient(url, anonKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });

    const email = `${nama}@owner.mitramajutani.invalid`;

    const { data, error } = await authClient.auth.signInWithPassword({
      email,
      password: sandi,
    });

    if (error || !data.session) {
      return json({ error: "Username atau kata sandi salah" }, 401);
    }

    return json({
      success: true,
      message: "Login berhasil",
      username: nama,
      session: {
        access_token: data.session.access_token,
        refresh_token: data.session.refresh_token,
        expires_at: data.session.expires_at,
        token_type: data.session.token_type,
      },
    });

  } catch (error) {
    console.error(error);
    return json({ error: "Terjadi kesalahan pada server" }, 500);
  }
});
