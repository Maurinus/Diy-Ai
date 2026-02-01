/// <reference lib="deno.ns" />
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

type DiagnosisPayload = {
  issueTitle: string;
  confidence: number;
  difficulty: "Easy" | "Medium" | "Hard";
  estimatedMinutes: number;
  highLevelOverview: string[];
  tools: { name: string; quantity: number; mustHave: boolean }[];
  parts: { name: string; variants: string[]; notes: string }[];
  steps: { order: number; title: string; detail: string }[];
  safetyChecklist: string[];
  commonMistakes: string[];
  verifyBeforeBuy: string[];
};

const fixtures: DiagnosisPayload[] = [
  {
    issueTitle: "Loose cabinet hinge causing door sag",
    confidence: 86,
    difficulty: "Easy",
    estimatedMinutes: 25,
    highLevelOverview: [
      "Tighten hinge screws and inspect for stripped holes",
      "Replace hinge or add wood filler if the screws won't hold",
      "Realign the door to restore even gaps",
    ],
    tools: [
      { name: "Phillips screwdriver", quantity: 1, mustHave: true },
      { name: "Wood filler", quantity: 1, mustHave: false },
      { name: "Drill with 1/8 in bit", quantity: 1, mustHave: false },
    ],
    parts: [
      {
        name: "Cabinet hinge",
        variants: ["35mm cup", "Overlay"],
        notes: "Match the cup diameter and overlay style.",
      },
      {
        name: "#6 wood screws",
        variants: ["1 in", "1-1/4 in"],
        notes: "Longer screws help if holes are stripped.",
      },
    ],
    steps: [
      { order: 1, title: "Inspect the hinge", detail: "Check if the hinge plate is loose or bent." },
      { order: 2, title: "Tighten screws", detail: "Tighten all hinge screws and test alignment." },
      { order: 3, title: "Check screw holes", detail: "If screws spin, remove them and inspect holes." },
      { order: 4, title: "Reinforce holes", detail: "Add wood filler or toothpicks with glue, then let dry." },
      { order: 5, title: "Re-drill pilot holes", detail: "Drill a small pilot hole to prevent splitting." },
      { order: 6, title: "Reinstall hinge", detail: "Reattach the hinge using longer screws if needed." },
      { order: 7, title: "Adjust alignment", detail: "Use adjustment screws to align door gaps." },
      { order: 8, title: "Final check", detail: "Open and close the door to confirm smooth movement." },
    ],
    safetyChecklist: ["Keep fingers clear of hinge pinch points", "Wear eye protection when drilling"],
    commonMistakes: [
      "Overtightening and stripping hinge screws",
      "Replacing the hinge without matching overlay style",
    ],
    verifyBeforeBuy: [
      "Confirm the hinge cup diameter (typically 35mm)",
      "Check overlay type to match the existing door",
    ],
  },
  {
    issueTitle: "Leaky faucet handle at base",
    confidence: 78,
    difficulty: "Medium",
    estimatedMinutes: 40,
    highLevelOverview: [
      "Shut off water and remove handle",
      "Replace worn cartridge or O-rings",
      "Reassemble and test for leaks",
    ],
    tools: [
      { name: "Adjustable wrench", quantity: 1, mustHave: true },
      { name: "Allen key set", quantity: 1, mustHave: true },
      { name: "Needle-nose pliers", quantity: 1, mustHave: false },
    ],
    parts: [
      {
        name: "Faucet cartridge",
        variants: ["Ceramic", "Compression"],
        notes: "Match the faucet brand and model.",
      },
      {
        name: "O-ring set",
        variants: ["Standard", "Metric"],
        notes: "Bring the old O-ring to match size.",
      },
    ],
    steps: [
      { order: 1, title: "Turn off water", detail: "Shut off the hot and cold supply valves." },
      { order: 2, title: "Remove handle", detail: "Locate the set screw and remove the handle." },
      { order: 3, title: "Inspect cartridge", detail: "Check the cartridge for wear or cracks." },
      { order: 4, title: "Remove cartridge", detail: "Use pliers to pull the cartridge straight out." },
      { order: 5, title: "Replace seals", detail: "Swap O-rings and lubricate lightly." },
      { order: 6, title: "Install new cartridge", detail: "Seat the cartridge and align tabs." },
      { order: 7, title: "Reassemble handle", detail: "Reattach the handle and tighten the set screw." },
      { order: 8, title: "Test", detail: "Turn water back on and check for leaks." },
    ],
    safetyChecklist: ["Turn off water before disassembly", "Cover the drain to avoid losing parts"],
    commonMistakes: ["Forcing the cartridge out and damaging housing", "Not matching the cartridge model"],
    verifyBeforeBuy: ["Confirm faucet brand and model", "Match cartridge stem length and spline count"],
  },
  {
    issueTitle: "Drawer sticking and not closing fully",
    confidence: 82,
    difficulty: "Easy",
    estimatedMinutes: 30,
    highLevelOverview: [
      "Check slides for debris or misalignment",
      "Tighten mounting screws and adjust",
      "Lubricate slides if needed",
    ],
    tools: [
      { name: "Screwdriver", quantity: 1, mustHave: true },
      { name: "Bubble level", quantity: 1, mustHave: false },
      { name: "Lubricant spray", quantity: 1, mustHave: false },
    ],
    parts: [
      {
        name: "Drawer slide set",
        variants: ["Side-mount", "Soft-close"],
        notes: "Match the slide length to the drawer depth.",
      },
    ],
    steps: [
      { order: 1, title: "Remove drawer", detail: "Release the slide clips and pull the drawer out." },
      { order: 2, title: "Inspect slides", detail: "Look for debris or bent rails." },
      { order: 3, title: "Clean rails", detail: "Wipe down slides and remove debris." },
      { order: 4, title: "Check mounting screws", detail: "Tighten any loose mounting screws." },
      { order: 5, title: "Realign slides", detail: "Use a level to ensure slides are parallel." },
      { order: 6, title: "Lubricate", detail: "Apply a light lubricant to the slide rails." },
      { order: 7, title: "Reinstall drawer", detail: "Align and slide the drawer back in." },
      { order: 8, title: "Test operation", detail: "Open and close fully to confirm smooth action." },
    ],
    safetyChecklist: ["Support the drawer to avoid drops", "Keep hands clear of pinch points"],
    commonMistakes: ["Replacing slides without matching length", "Over-lubricating and attracting debris"],
    verifyBeforeBuy: ["Measure drawer depth for slide length", "Confirm slide type (side-mount vs soft-close)"],
  },
];

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (!supabaseUrl || !supabaseAnonKey) {
    return new Response(JSON.stringify({ error: "Supabase environment missing" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return new Response(JSON.stringify({ error: "Missing Authorization header" }), {
      status: 401,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  let jobId: string | null = null;

  try {
    const { data: userData, error: userError } = await supabase.auth.getUser();
    if (userError || !userData?.user) {
      return new Response(JSON.stringify({ error: "Invalid token" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const body = await req.json();
    const { job_id, category, note, image_url } = body ?? {};
    if (!job_id || !image_url) {
      return new Response(JSON.stringify({ error: "Missing job_id or image_url" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
    jobId = job_id;

    await supabase.from("profiles").upsert({ id: userData.user.id }, { onConflict: "id" });

    const { data: profile } = await supabase
      .from("profiles")
      .select("id,is_pro,daily_count,daily_count_date")
      .eq("id", userData.user.id)
      .single();

    const today = new Date().toISOString().slice(0, 10);
    const isPro = profile?.is_pro ?? false;
    let dailyCount = profile?.daily_count ?? 0;
    const dailyDate = profile?.daily_count_date ?? today;
    if (dailyDate !== today) {
      dailyCount = 0;
    }
    const limit = isPro ? 50 : 5;
    if (dailyCount >= limit) {
      return new Response(JSON.stringify({ error: "Daily limit reached" }), {
        status: 429,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    await supabase
      .from("profiles")
      .update({ daily_count: dailyCount + 1, daily_count_date: today })
      .eq("id", userData.user.id);

    await supabase.from("repair_jobs").update({ status: "analyzing" }).eq("id", job_id);

    const aiKey = Deno.env.get("AI_API_KEY");
    let result: DiagnosisPayload;

    if (!aiKey) {
      result = fixtures[Math.floor(Math.random() * fixtures.length)];
    } else {
      result = await callVisionModel({
        apiKey: aiKey,
        imageUrl: image_url,
        category,
        note,
      });
    }

    const normalized = normalizeResult(result);

    const insertPayload = {
      job_id,
      issue_title: normalized.issueTitle,
      confidence: normalized.confidence,
      difficulty: normalized.difficulty,
      estimated_minutes: normalized.estimatedMinutes,
      high_level_overview: normalized.highLevelOverview,
      tools: normalized.tools,
      parts: normalized.parts,
      steps: normalized.steps,
      safety_checklist: normalized.safetyChecklist,
      common_mistakes: normalized.commonMistakes,
      verify_before_buy: normalized.verifyBeforeBuy,
    };

    const { error: insertError } = await supabase
      .from("diagnosis_results")
      .upsert(insertPayload, { onConflict: "job_id" });

    if (insertError) {
      throw insertError;
    }

    await supabase.from("repair_jobs").update({ status: "done" }).eq("id", job_id);

    return new Response(JSON.stringify(normalized), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    if (jobId) {
      await supabase.from("repair_jobs").update({ status: "error", error_message: String(error) }).eq("id", jobId);
    }
    return new Response(JSON.stringify({ error: String(error) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

async function callVisionModel(params: {
  apiKey: string;
  imageUrl: string;
  category?: string;
  note?: string;
}): Promise<DiagnosisPayload> {
  const model = Deno.env.get("AI_MODEL") ?? "gpt-4o-mini";
  const apiUrl = Deno.env.get("AI_API_URL") ?? "https://api.openai.com/v1/chat/completions";

  const systemPrompt = `You are a repair diagnostics assistant. Return ONLY valid JSON matching this schema:
{
  "issueTitle": string,
  "confidence": number 0-100,
  "difficulty": "Easy"|"Medium"|"Hard",
  "estimatedMinutes": number,
  "highLevelOverview": string[],
  "tools": [{"name":string,"quantity":number,"mustHave":boolean}],
  "parts": [{"name":string,"variants":string[],"notes":string}],
  "steps": [{"order":number,"title":string,"detail":string}],
  "safetyChecklist": string[],
  "commonMistakes": string[],
  "verifyBeforeBuy": string[]
}

Rules: Provide 8-12 steps. Keep language concise and practical.`;

  const userPrompt = `Category: ${params.category ?? "Unknown"}\nNotes: ${params.note ?? "None"}\nAnalyze the image and produce the JSON.`;

  const body = {
    model,
    temperature: 0.2,
    messages: [
      { role: "system", content: systemPrompt },
      {
        role: "user",
        content: [
          { type: "text", text: userPrompt },
          { type: "image_url", image_url: { url: params.imageUrl } },
        ],
      },
    ],
  };

  const response = await fetch(apiUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${params.apiKey}`,
    },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(`AI provider error: ${response.status} ${text}`);
  }

  const data = await response.json();
  const message = data.choices?.[0]?.message?.content ?? data.output_text ?? data.output?.[0]?.content?.[0]?.text;
  if (!message) {
    throw new Error("AI response missing content");
  }

  const jsonText = extractJSON(String(message));
  const parsed = JSON.parse(jsonText);
  return parsed as DiagnosisPayload;
}

function extractJSON(text: string): string {
  const first = text.indexOf("{");
  const last = text.lastIndexOf("}");
  if (first === -1 || last === -1 || last <= first) {
    throw new Error("Unable to parse JSON from AI response");
  }
  return text.slice(first, last + 1);
}

function normalizeResult(payload: DiagnosisPayload): DiagnosisPayload {
  return {
    issueTitle: payload.issueTitle ?? "Unknown issue",
    confidence: clampNumber(payload.confidence ?? 60, 0, 100),
    difficulty: payload.difficulty ?? "Medium",
    estimatedMinutes: clampNumber(payload.estimatedMinutes ?? 30, 1, 240),
    highLevelOverview: Array.isArray(payload.highLevelOverview) ? payload.highLevelOverview : [],
    tools: Array.isArray(payload.tools) ? payload.tools : [],
    parts: Array.isArray(payload.parts) ? payload.parts : [],
    steps: Array.isArray(payload.steps) ? payload.steps : [],
    safetyChecklist: Array.isArray(payload.safetyChecklist) ? payload.safetyChecklist : [],
    commonMistakes: Array.isArray(payload.commonMistakes) ? payload.commonMistakes : [],
    verifyBeforeBuy: Array.isArray(payload.verifyBeforeBuy) ? payload.verifyBeforeBuy : [],
  };
}

function clampNumber(value: number, min: number, max: number): number {
  if (Number.isNaN(value)) return min;
  return Math.min(Math.max(value, min), max);
}
