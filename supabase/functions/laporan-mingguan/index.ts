import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3"

const TELEGRAM_TOKEN = "8908433352:AAFDNsMQC4VPWervEkDRAbnHHF1Zdrzd_P4";
const CHAT_ID = "6717823700";

serve(async (req) => {
  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
  const supabase = createClient(supabaseUrl, supabaseKey);

  // Ambil data 7 hari terakhir
  const lastWeek = new Date();
  lastWeek.setDate(lastWeek.getDate() - 7);

  const { data, error } = await supabase
    .from('bookings')
    .select('*, vehicles(registration_no), profiles(full_name)')
    .eq('status', 'completed')
    .gte('created_at', lastWeek.toISOString());

  if (error) return new Response(error.message, { status: 500 });

  // Susun format pesan
  let text = `📊 *Laporan Peminjaman Mingguan*\n\n`;
  text += `Total Kendaraan Kembali: ${data?.length || 0} sesi\n\n`;
  
  data?.forEach((item, i) => {
    const driver = item.profiles?.full_name || 'Unknown';
    const plat = item.vehicles?.registration_no || '-';
    text += `${i + 1}. ${driver} (${plat})\n`;
  });

  // Kirim ke Telegram
  await fetch(`https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ chat_id: CHAT_ID, text: text, parse_mode: 'Markdown' }),
  });

  return new Response(JSON.stringify({ success: true }), { headers: { 'Content-Type': 'application/json' }});
});