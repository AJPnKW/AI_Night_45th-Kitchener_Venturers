window.siteConfig = Object.assign(
  {
    formEndpoint: "",
    formServiceName: "Local workbook only",
    surveyPlatformName: "Google Forms",
    preEventSurveyUrl: "",
    feedbackSurveyUrl: "",
    surveyStatusLabel: "Survey status",
    surveyStatusValue: "Organizer-owned Google Forms are the canonical survey path. Public URLs are not stored in this repository.",
    volunteerContactLabel: "Volunteer organizer contact",
    volunteerContactValue: "Use the event communication channel shared by your unit leaders or presenter.",
    submissionInboxLabel: "Workbook storage",
    submissionInboxValue: "Participant workbook notes stay in this browser unless the learner chooses to print or download them.",
    submissionInboxUrl: "",
    responseSheetLabel: "Form response handling",
    responseSheetValue: "Canonical form handling is Google Forms to Google Sheets. Live organizer-owned form links are managed outside the public repo.",
    responseSheetUrl: "",
    responseSheetCsvUrl: "",
    eventDateLabel: "April 14, 2026",
    eventLocationLabel: "Hope Lutheran Pres Church, 30 Shaftsbury",
    formStoragePrefix: "browser_first_ai_night_"
  },
  window.siteConfig || {}
);

function getBasePath() {
  const repoPath = "/AI_Night_1st-Stanley-Park_Venture-Company";
  if (window.location.hostname.endsWith("github.io") || window.location.pathname.startsWith(`${repoPath}/`) || window.location.pathname === repoPath) {
    return repoPath;
  }
  return "";
}

function withBase(path) {
  if (!path) {
    return getBasePath() || "/";
  }
  if (/^https?:\/\//.test(path) || path.startsWith("mailto:") || path.startsWith("#")) {
    return path;
  }
  const normalized = path.startsWith("/") ? path : `/${path}`;
  return `${getBasePath()}${normalized}`;
}

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function parseCsv(text) {
  const rows = [];
  let row = [];
  let value = "";
  let inQuotes = false;

  for (let index = 0; index < text.length; index += 1) {
    const char = text[index];
    const next = text[index + 1];

    if (char === '"') {
      if (inQuotes && next === '"') {
        value += '"';
        index += 1;
      } else {
        inQuotes = !inQuotes;
      }
      continue;
    }

    if (char === "," && !inQuotes) {
      row.push(value);
      value = "";
      continue;
    }

    if ((char === "\n" || char === "\r") && !inQuotes) {
      if (char === "\r" && next === "\n") {
        index += 1;
      }
      row.push(value);
      if (row.some((cell) => cell !== "")) {
        rows.push(row);
      }
      row = [];
      value = "";
      continue;
    }

    value += char;
  }

  row.push(value);
  if (row.some((cell) => cell !== "")) {
    rows.push(row);
  }

  return rows;
}

const workbookMatrix = {
  "Prompt improvement": {
    Guided: {
      starter: "Help me learn history.",
      tip: "Add the topic, who it is for, and the format you want back.",
      followup: "If the answer is still weak, add one limit such as length, reading level, or bullet points.",
      extension: "Remix the same prompt for a different subject or a different audience."
    },
    Build: {
      starter: "Help me get ready for camp.",
      tip: "Say what kind of help you want: checklist, schedule, explanation, or message.",
      followup: "Compare your first improved prompt with a second version that adds a real-world limit.",
      extension: "Turn the answer into a checklist and a short message version."
    },
    Remix: {
      starter: "Tell me about Vancouver.",
      tip: "Ask for a purpose, like planning a visit, learning history, or finding family-friendly ideas.",
      followup: "Adapt the same prompt for a younger learner, a tourist, or a parent.",
      extension: "Create two versions with different tones and compare which one is more useful."
    },
    Stretch: {
      starter: "Help me plan a project.",
      tip: "Break the project into steps, success criteria, and a simple timeline.",
      followup: "Ask the tool to critique its own first answer and then improve it.",
      extension: "Create a version for a teacher and a version for a friend, then compare the changes."
    }
  },
  "Summarize and refine": {
    Guided: {
      starter: "Summarize this article.",
      tip: "Say how short the summary should be and what should stay in plain language.",
      followup: "If the summary is vague, ask for fewer points with clearer wording.",
      extension: "Turn the summary into study notes or a short checklist."
    },
    Build: {
      starter: "Summarize this and make it better.",
      tip: "Name the audience and ask what 'better' means, such as clearer, shorter, or more organized.",
      followup: "Ask for the same content in a different format like bullets, Q&A, or flashcards.",
      extension: "Create a summary and a one-minute speaking version."
    },
    Remix: {
      starter: "Explain this video.",
      tip: "Ask for a plain-language explanation and one example or analogy.",
      followup: "Change the audience and see what explanation changes.",
      extension: "Ask for both a beginner explanation and a more detailed version."
    },
    Stretch: {
      starter: "Turn this into study notes.",
      tip: "Ask for sections, key terms, and a small self-check at the end.",
      followup: "If the notes feel too long, ask the model to rank what matters most.",
      extension: "Build a quiz from the notes and test whether the notes were actually useful."
    }
  },
  "Tone and audience rewrite": {
    Guided: {
      starter: "Rewrite this message.",
      tip: "Say who it is for and what tone you want, like polite, friendly, or clear.",
      followup: "If the rewrite still sounds off, add a word limit and ask what to remove.",
      extension: "Write a teacher version and a friend version and compare them."
    },
    Build: {
      starter: "Make this sound better.",
      tip: "Replace 'better' with a real goal such as calmer, shorter, more respectful, or more direct.",
      followup: "Ask for two options and pick which one best matches your purpose.",
      extension: "Turn the message into both an email and a short text reminder."
    },
    Remix: {
      starter: "Rewrite this camp announcement.",
      tip: "Name the readers and say what action you want them to take.",
      followup: "If the call to action is weak, ask for a stronger closing line.",
      extension: "Adapt it for a parent, a youth participant, and a leader."
    },
    Stretch: {
      starter: "Turn this into a short speech.",
      tip: "Ask for a speaking tone, a clear opening, and a closing line.",
      followup: "If it feels stiff, ask for more natural spoken wording.",
      extension: "Ask for two versions: one formal and one more energetic."
    }
  },
  "Image prompt design": {
    Guided: {
      starter: "Make a poster for camp.",
      tip: "Start with subject, then add mood, colours, and layout.",
      followup: "If the image feels random, add a style word and one composition detail.",
      extension: "Make a second version for a different time of day."
    },
    Build: {
      starter: "Make a cool logo.",
      tip: "Name the shape, symbols, colour style, and whether it should feel modern or playful.",
      followup: "If the logo is too busy, ask for a simpler badge version.",
      extension: "Create a matching sticker version and compare them."
    },
    Remix: {
      starter: "Create an event image.",
      tip: "Say what event it is for and what feeling the image should create.",
      followup: "Change one thing at a time: audience, colour palette, or style.",
      extension: "Remix it for poster, sticker, and social tile formats."
    },
    Stretch: {
      starter: "Create a set of matching images.",
      tip: "Ask for a consistent style guide across the set.",
      followup: "If the images do not match, repeat the style, colours, and layout rules in each prompt.",
      extension: "Create a mini visual system with a poster, badge, and banner."
    }
  },
  "Reflection on AI output quality": {
    Guided: {
      starter: "Which answer is better?",
      tip: "Do not stop at 'better' or 'worse'. Name what made one output more useful.",
      followup: "If you are unsure, compare the outputs against one goal or audience.",
      extension: "Write one sentence explaining which answer you would trust less and why."
    },
    Build: {
      starter: "Compare these two outputs.",
      tip: "Look for clarity, fit for purpose, and whether anything sounds too confident.",
      followup: "Name one thing the better output still got wrong or missed.",
      extension: "Rank the outputs on usefulness, clarity, and trust."
    },
    Remix: {
      starter: "Why is this not quite right?",
      tip: "Describe the gap: missing detail, wrong tone, weak structure, or shaky facts.",
      followup: "Turn the gap into one better follow-up prompt.",
      extension: "Compare how the same answer would land for two different audiences."
    },
    Stretch: {
      starter: "What would you verify before trusting this output?",
      tip: "List the facts, dates, names, or claims that need checking.",
      followup: "Ask the model to show uncertainty or list questions instead of pretending certainty.",
      extension: "Create a small checklist for safe AI use after the event."
    }
  },
  "Optional Codex observation task": {
    Guided: {
      starter: "Watch the facilitator demo and name one useful constraint.",
      tip: "Look for what was requested, how big it should be, and what had to be included.",
      followup: "Explain how the same lesson applies to a browser prompt.",
      extension: "Write one prompt rule you want to remember."
    },
    Build: {
      starter: "Explain what Codex is and is not.",
      tip: "Keep the focus on prompt clarity, not on coding status.",
      followup: "Name one risk of a vague coding request and one benefit of a clear one.",
      extension: "Rewrite the weak coding request to make it easier to review."
    },
    Remix: {
      starter: "Adapt the coding demo lesson back into a browser-only prompt lesson.",
      tip: "Map code constraints to normal prompt constraints like audience, format, and limits.",
      followup: "Name one thing that stayed the same across both tools.",
      extension: "Create a short 'same lesson, different tool' comparison."
    },
    Stretch: {
      starter: "Explain why the coding demo is optional and secondary.",
      tip: "Connect the answer back to the browser-first goal of the event.",
      followup: "Name why over-focusing on advanced tools would derail the main workshop.",
      extension: "Write a short leader note about when not to introduce advanced tools."
    }
  }
};

const workbookFieldLabels = {
  participant_name: "Your name or initials",
  interest_topic: "Topic you want to work on tonight",
  level: "Exercise level",
  category: "Exercise category",
  session_goal: "What you want this workbook to help you do",
  comfort_support: "What would help you feel comfortable tonight",
  help_flag: "Leader or facilitator check-in",
  starter: "Weak starter prompt",
  improved: "Your improved prompt",
  changes: "What changed in your prompt",
  expectation: "What you were hoping for",
  output_quality: "Output quality so far",
  result: "Did the result meet your expectation",
  gap: "What gap remained",
  verify: "What you would still verify",
  coaching_response: "Next improvement you want to try",
  image_goal: "What image you were trying to create",
  image_starter: "Weak image prompt",
  image_improved: "Improved image prompt",
  image_changes: "What changed in the image prompt",
  image_result: "How close the image result was",
  image_gap: "What you would improve next",
  extension: "Fast-finisher extension",
  codex_note: "Optional Codex observation note",
  reflection_changed: "What changed most",
  reflection_worked: "What worked better than expected",
  reflection_surprised: "What surprised you",
  reflection_different: "What you would do differently next time",
  safe_use: "What you would still check before trusting AI output",
  takeaway: "What you want to keep after tonight",
  next: "Where you could use this safely after tonight"
};

const workbookFlowSteps = [
  { slug: "workbook", completeIf: ["participant_name", "interest_topic", "session_goal"] },
  { slug: "exercises", completeIf: ["starter", "improved", "changes"] },
  { slug: "image-lab", completeIf: ["image_goal", "image_improved", "image_changes"] },
  { slug: "reflections", completeIf: ["reflection_changed", "takeaway", "next"] }
];

function getStorageKey(form) {
  return `${window.siteConfig.formStoragePrefix}${form.dataset.draftKey || form.id || "form"}`;
}

function readStoredPayloadFromKey(key) {
  const raw = localStorage.getItem(key);
  if (!raw) {
    return {};
  }
  try {
    return JSON.parse(raw) || {};
  } catch {
    localStorage.removeItem(key);
    return {};
  }
}

function readStoredPayload(form) {
  return readStoredPayloadFromKey(getStorageKey(form));
}

function getWorkbookState(form) {
  const category = form.querySelector("[name='category']")?.value || "Prompt improvement";
  const level = form.querySelector("[name='level']")?.value || "Guided";
  const result = form.querySelector("[name='result']")?.value || "";
  const quality = form.querySelector("[name='output_quality']")?.value || "";
  return { category, level, result, quality };
}

function updateWorkbookAssistant(form) {
  if (form.dataset.workbookAssistant !== "true") {
    return;
  }

  const helper = form.querySelector("[data-workbook-helper]");
  if (!helper) {
    return;
  }

  const { category, level, result, quality } = getWorkbookState(form);
  const categoryMap = workbookMatrix[category] || workbookMatrix["Prompt improvement"];
  const content = categoryMap[level] || categoryMap.Guided;

  const starterNode = helper.querySelector("[data-helper-starter]");
  const tipNode = helper.querySelector("[data-helper-tip]");
  const followupNode = helper.querySelector("[data-helper-followup]");
  const extensionNode = helper.querySelector("[data-helper-extension]");

  if (starterNode) {
    starterNode.textContent = content.starter;
  }
  if (tipNode) {
    tipNode.textContent = content.tip;
  }

  let followup = content.followup;
  if (result === "Not yet" || quality === "Still weak") {
    followup = `${content.followup} Narrow the ask and add one concrete detail before trying again.`;
  } else if (result === "Partly" || quality === "Getting closer") {
    followup = `${content.followup} Keep the good parts and improve one gap at a time.`;
  } else if (result === "Yes, mostly" || quality === "Useful already") {
    followup = "You have something workable. Now improve tone, format, or audience fit rather than starting over.";
  }

  if (followupNode) {
    followupNode.textContent = followup;
  }
  if (extensionNode) {
    extensionNode.textContent = content.extension;
  }

  const starterField = form.querySelector("[name='starter']");
  if (starterField && !starterField.value.trim()) {
    starterField.value = content.starter;
  }
}

function updateSummary(form) {
  const target = document.querySelector(form.dataset.summaryTarget || "");
  if (!target) {
    return;
  }

  const merged = readStoredPayload(form);
  form.querySelectorAll("input, select, textarea").forEach((field) => {
    if (!field.name || field.type === "button" || field.type === "submit") {
      return;
    }

    let value = "";
    if (field.type === "checkbox") {
      if (!field.checked) {
        return;
      }
      value = field.value || "Yes";
    } else if (field.type === "radio") {
      if (!field.checked) {
        return;
      }
      value = field.value;
    } else {
      value = field.value.trim();
    }
    merged[field.name] = value;
  });

  const pairs = Object.entries(merged)
    .filter(([, value]) => String(value || "").trim() !== "" && value !== false)
    .map(([name, value]) => [workbookFieldLabels[name] || name, String(value)]);

  if (!pairs.length) {
    target.innerHTML = "<p class=\"small\">Your entered details will appear here so you can print or save them.</p>";
    return;
  }

  target.innerHTML = `<dl class="summary-list">${pairs.map(([name, value]) => `<div><dt>${name}</dt><dd>${value}</dd></div>`).join("")}</dl>`;
}

function saveDraft(form) {
  const key = getStorageKey(form);
  const payload = readStoredPayloadFromKey(key);

  form.querySelectorAll("input, select, textarea").forEach((field) => {
    if (!field.name || field.type === "submit" || field.type === "button") {
      return;
    }

    if (field.type === "checkbox") {
      payload[field.name] = field.checked;
    } else if (field.type === "radio") {
      if (field.checked) {
        payload[field.name] = field.value;
      }
    } else {
      payload[field.name] = field.value;
    }
  });

  localStorage.setItem(key, JSON.stringify(payload));
  return key;
}

function loadDraft(form) {
  const payload = readStoredPayload(form);
  form.querySelectorAll("input, select, textarea").forEach((field) => {
    if (!field.name || !(field.name in payload)) {
      return;
    }

    if (field.type === "checkbox") {
      field.checked = Boolean(payload[field.name]);
    } else if (field.type === "radio") {
      field.checked = payload[field.name] === field.value;
    } else {
      field.value = payload[field.name];
    }
  });
}

function downloadDraft(form) {
  const payload = readStoredPayload(form);
  form.querySelectorAll("input, select, textarea").forEach((field) => {
    if (!field.name || field.type === "submit" || field.type === "button") {
      return;
    }
    if (field.type === "checkbox") {
      payload[field.name] = field.checked;
    } else if (field.type === "radio") {
      if (field.checked) {
        payload[field.name] = field.value;
      }
    } else {
      payload[field.name] = field.value;
    }
  });

  const blob = new Blob([JSON.stringify(payload, null, 2)], { type: "application/json" });
  const href = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = href;
  link.download = `${form.dataset.downloadName || "ai-night-form"}.json`;
  link.click();
  URL.revokeObjectURL(href);
}

function renderWorkbookSnapshot(target) {
  const draftKey = target.dataset.workbookSnapshot;
  if (!draftKey) {
    return;
  }

  const payload = readStoredPayloadFromKey(`${window.siteConfig.formStoragePrefix}${draftKey}`);
  const pairs = Object.entries(payload)
    .filter(([, value]) => String(value || "").trim() !== "" && value !== false)
    .map(([name, value]) => [workbookFieldLabels[name] || name, String(value)]);

  if (!pairs.length) {
    target.innerHTML = "<p class=\"small\">Your saved workbook notes will appear here as you fill them in.</p>";
    return;
  }

  target.innerHTML = `<dl class="summary-list">${pairs.map(([name, value]) => `<div><dt>${escapeHtml(name)}</dt><dd>${escapeHtml(value)}</dd></div>`).join("")}</dl>`;
}

function updateWorkbookFlowStatus() {
  const payload = readStoredPayloadFromKey(`${window.siteConfig.formStoragePrefix}participant_workbook`);
  const resumeNode = document.querySelector("[data-workbook-resume]");
  let furthestCompleted = "Start and setup";

  workbookFlowSteps.forEach((step) => {
    const card = document.querySelector(`[data-workbook-step="${step.slug}"]`);
    const complete = step.completeIf.some((field) => String(payload[field] || "").trim() !== "");
    if (card) {
      const titleNode = card.querySelector("h3");
      const badge = card.querySelector("[data-workbook-complete-badge]");
      if (complete) {
        card.classList.add("is-complete");
        if (!badge && titleNode) {
          titleNode.insertAdjacentHTML("beforeend", " <span class=\"small\" data-workbook-complete-badge>Saved</span>");
        }
      } else {
        card.classList.remove("is-complete");
        badge?.remove();
      }
    }
    if (complete) {
      const match = workbookFlowSteps.find((item) => item.slug === step.slug);
      if (match) {
        const labelMap = {
          workbook: "Start and setup",
          exercises: "Prompt practice",
          "image-lab": "Image and extension lab",
          reflections: "Reflection and summary"
        };
        furthestCompleted = labelMap[step.slug] || furthestCompleted;
      }
    }
  });

  if (resumeNode) {
    resumeNode.textContent = `Your workbook engine is saving locally in this browser. If you leave and come back on this device, you should be able to resume from ${furthestCompleted}.`;
  }
}

function updateAgeNotice(form) {
  const ageField = form.querySelector("[data-age-on-event]");
  const note = document.querySelector(form.dataset.ageNoticeTarget || "");
  if (!ageField || !note) {
    return;
  }

  const age = Number.parseInt(ageField.value, 10);
  if (Number.isNaN(age)) {
    note.innerHTML = `<p>Enter age on ${window.siteConfig.eventDateLabel}. Parent or guardian approval is generally expected for youth participants.</p>`;
    return;
  }

  if (age < 18) {
    note.innerHTML = `<p><strong>Parent / guardian action required:</strong> because the participant is under 18 on ${window.siteConfig.eventDateLabel}, complete the parent waiver before the event.</p>`;
  } else {
    note.innerHTML = `<p><strong>Review still required:</strong> this participant is 18 or older on ${window.siteConfig.eventDateLabel}. Confirm with the event leaders whether parent approval is still expected for this session.</p>`;
  }
}

function initWorkflowForm(form) {
  loadDraft(form);
  updateWorkbookAssistant(form);
  updateSummary(form);
  updateAgeNotice(form);
  document.querySelectorAll("[data-workbook-snapshot]").forEach((target) => renderWorkbookSnapshot(target));
  updateWorkbookFlowStatus();

  form.addEventListener("input", () => {
    saveDraft(form);
    updateWorkbookAssistant(form);
    updateSummary(form);
    updateAgeNotice(form);
    document.querySelectorAll("[data-workbook-snapshot]").forEach((target) => renderWorkbookSnapshot(target));
    updateWorkbookFlowStatus();
  });

  form.addEventListener("change", () => {
    saveDraft(form);
    updateWorkbookAssistant(form);
    updateSummary(form);
    updateAgeNotice(form);
    document.querySelectorAll("[data-workbook-snapshot]").forEach((target) => renderWorkbookSnapshot(target));
    updateWorkbookFlowStatus();
  });

  form.addEventListener("submit", (event) => {
    const status = form.closest(".form-shell")?.querySelector("[data-form-status]");
    event.preventDefault();
    saveDraft(form);
    updateSummary(form);
    document.querySelectorAll("[data-workbook-snapshot]").forEach((target) => renderWorkbookSnapshot(target));
    updateWorkbookFlowStatus();
    if (status) {
      status.textContent = "This workbook stays on this device. Use Save in this browser, Download report, or Print / Save as PDF. Pre-event and feedback collection are handled separately through organizer-issued Google Forms.";
    }
  });

  const saveSelector = form.dataset.saveButton;
  const saveButton = form.querySelector("[data-save-draft]") || (saveSelector ? document.querySelector(saveSelector) : null);
  if (saveButton) {
    saveButton.addEventListener("click", () => {
      saveDraft(form);
      const status = form.closest(".form-shell")?.querySelector("[data-form-status]");
      if (status) {
        status.textContent = "Draft saved on this device.";
      }
      document.querySelectorAll("[data-workbook-snapshot]").forEach((target) => renderWorkbookSnapshot(target));
      updateWorkbookFlowStatus();
    });
  }

  const downloadSelector = form.dataset.downloadButton;
  const downloadButton = form.querySelector("[data-download-draft]") || (downloadSelector ? document.querySelector(downloadSelector) : null);
  if (downloadButton) {
    downloadButton.addEventListener("click", () => {
      updateSummary(form);
      downloadDraft(form);
    });
  }

  const printSelector = form.dataset.printButton;
  const printButton = form.querySelector("[data-print-page]") || (printSelector ? document.querySelector(printSelector) : null);
  if (printButton) {
    printButton.addEventListener("click", () => {
      updateSummary(form);
      window.print();
    });
  }

  const clearSelector = form.dataset.clearButton;
  const clearButton = clearSelector ? document.querySelector(clearSelector) : null;
  if (clearButton) {
    clearButton.addEventListener("click", () => {
      form.reset();
      saveDraft(form);
      updateWorkbookAssistant(form);
      updateSummary(form);
      updateAgeNotice(form);
      document.querySelectorAll("[data-workbook-snapshot]").forEach((target) => renderWorkbookSnapshot(target));
      updateWorkbookFlowStatus();
    });
  }
}

async function initSubmissionDashboard() {
  const shell = document.querySelector("[data-submissions-dashboard]");
  if (!shell) {
    return;
  }

  const status = shell.querySelector("[data-submissions-status]");
  const tableTarget = shell.querySelector("[data-submissions-table]");

  if (!window.siteConfig.responseSheetCsvUrl) {
    if (status) {
      status.textContent = "No shared response table is configured in this public repo. The canonical path is organizer-owned Google Forms connected to Google Sheets.";
    }
    if (tableTarget) {
      tableTarget.innerHTML = "<p class=\"small\">If the organizer later wants a live response dashboard, publish a Google Sheet as CSV and place the CSV URL in assets/js/site-config.js. This remains optional and separate from the public GitHub Pages site.</p>";
    }
    return;
  }

  if (status) {
    status.textContent = "Loading response table...";
  }

  try {
    const response = await fetch(window.siteConfig.responseSheetCsvUrl, { cache: "no-store" });
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    const text = await response.text();
    const rows = parseCsv(text);
    if (!rows.length) {
      throw new Error("No rows found");
    }

    const [headers, ...bodyRows] = rows;
    if (!tableTarget) {
      return;
    }

    if (!bodyRows.length) {
      tableTarget.innerHTML = "<p class=\"small\">The response table is connected, but no submissions are visible yet.</p>";
    } else {
      tableTarget.innerHTML = `
        <div class="table-wrap">
          <table class="data-table">
            <thead>
              <tr>${headers.map((header) => `<th>${escapeHtml(header)}</th>`).join("")}</tr>
            </thead>
            <tbody>
              ${bodyRows.map((cells) => `<tr>${headers.map((_, index) => `<td>${escapeHtml(cells[index] || "")}</td>`).join("")}</tr>`).join("")}
            </tbody>
          </table>
        </div>
      `;
    }

    if (status) {
      status.textContent = `${bodyRows.length} submission record${bodyRows.length === 1 ? "" : "s"} loaded from the shared Google Sheets response table.`;
    }
  } catch (error) {
    if (status) {
      status.textContent = `The shared response table could not be loaded yet (${error.message}). Keep using the organizer-owned Google Form and response sheet outside the public repo.`;
    }
    if (tableTarget) {
      tableTarget.innerHTML = "<p class=\"small\">Check the published CSV URL in assets/js/site-config.js or keep using the organizer-owned Google Form and Google Sheet until the optional dashboard is ready.</p>";
    }
  }
}

document.addEventListener("DOMContentLoaded", () => {
  const nav = document.querySelector("[data-nav]");
  const toggle = document.querySelector("[data-menu-toggle]");
  if (nav && toggle) {
    toggle.addEventListener("click", () => {
      const open = nav.classList.toggle("open");
      toggle.setAttribute("aria-expanded", String(open));
      document.body.classList.toggle("menu-open", open);
    });
  }

  document.querySelectorAll("[data-current-path]").forEach((link) => {
    const target = link.getAttribute("href");
    const current = window.location.pathname.replace(/\/index\.html$/, "/");
    const normalizedTarget = target.replace(/index\.html$/, "");
    if (current.endsWith(normalizedTarget) || current === normalizedTarget) {
      link.setAttribute("aria-current", "page");
    }
  });

  document.querySelectorAll("[data-year]").forEach((node) => {
    node.textContent = new Date().getFullYear();
  });

  document.querySelectorAll("[data-form-status]").forEach((status) => {
    status.textContent = "This workbook is local to this browser. Save a draft locally, download the entered details, or print / save as PDF. Structured pre-event and feedback collection belong in organizer-issued Google Forms, not GitHub Pages.";
  });

  document.querySelectorAll("[data-contact-label]").forEach((node) => {
    node.textContent = window.siteConfig.volunteerContactLabel;
  });

  document.querySelectorAll("[data-contact-value]").forEach((node) => {
    node.textContent = window.siteConfig.volunteerContactValue;
  });

  document.querySelectorAll("[data-submission-inbox-label]").forEach((node) => {
    node.textContent = window.siteConfig.submissionInboxLabel;
  });

  document.querySelectorAll("[data-submission-inbox-value]").forEach((node) => {
    node.textContent = window.siteConfig.submissionInboxValue;
  });

  document.querySelectorAll("[data-submission-inbox-link]").forEach((node) => {
    if (window.siteConfig.submissionInboxUrl) {
      node.setAttribute("href", window.siteConfig.submissionInboxUrl);
    } else {
      node.removeAttribute("href");
      node.setAttribute("aria-disabled", "true");
      node.classList.add("disabled-link");
    }
  });

  document.querySelectorAll("[data-workflow-form]").forEach((form) => {
    initWorkflowForm(form);
  });

  document.querySelectorAll("[data-workbook-snapshot]").forEach((target) => {
    renderWorkbookSnapshot(target);
  });

  updateWorkbookFlowStatus();

  document.querySelectorAll("[data-response-sheet-label]").forEach((node) => {
    node.textContent = window.siteConfig.responseSheetLabel;
  });

  document.querySelectorAll("[data-response-sheet-value]").forEach((node) => {
    node.textContent = window.siteConfig.responseSheetValue;
  });

  document.querySelectorAll("[data-response-sheet-link]").forEach((node) => {
    if (window.siteConfig.responseSheetUrl) {
      node.setAttribute("href", window.siteConfig.responseSheetUrl);
    } else {
      node.removeAttribute("href");
      node.setAttribute("aria-disabled", "true");
      node.classList.add("disabled-link");
    }
  });

  document.querySelectorAll("[data-print-page]").forEach((button) => {
    button.addEventListener("click", () => window.print());
  });

  initSubmissionDashboard();
});

