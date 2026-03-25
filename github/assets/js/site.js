window.siteConfig = Object.assign(
  {
    formEndpoint: "",
    formServiceName: "Formspree-compatible endpoint",
    volunteerContactLabel: "Volunteer organizer contact",
    volunteerContactValue: "Configure in assets/js/site.js before publishing live approvals.",
    eventDateLabel: "April 14, 2026",
    eventLocationLabel: "Hope Lutheran Pres Church, 30 Shaftsbury",
    accessPasswords: {
      participant: "ScouterJenn",
      leader: "lEader",
      facilitator: "J@Hn"
    },
    formStoragePrefix: "ai_night_45th_"
  },
  window.siteConfig || {}
);

const ROLE_ROUTES = {
  participant: "/participant/index.html",
  leader: "/leader/index.html",
  facilitator: "/facilitator/index.html"
};

function getBasePath() {
  const repoPath = "/AI_Night_45th-Kitchener_Venturers";
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

function updateSummary(form) {
  const target = document.querySelector(form.dataset.summaryTarget || "");
  if (!target) {
    return;
  }

  const pairs = [];
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
      if (!value) {
        return;
      }
    }

    const label = form.querySelector(`label[for="${field.id}"]`);
    const name = label ? label.textContent.trim() : field.name;
    pairs.push([name, value]);
  });

  if (!pairs.length) {
    target.innerHTML = "<p class=\"small\">Your entered details will appear here so you can print or save them.</p>";
    return;
  }

  target.innerHTML = `<dl class="summary-list">${pairs.map(([name, value]) => `<div><dt>${name}</dt><dd>${value}</dd></div>`).join("")}</dl>`;
}

function saveDraft(form) {
  const key = `${window.siteConfig.formStoragePrefix}${form.dataset.draftKey || form.id || "form"}`;
  const payload = {};

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
  const key = `${window.siteConfig.formStoragePrefix}${form.dataset.draftKey || form.id || "form"}`;
  const raw = localStorage.getItem(key);
  if (!raw) {
    return;
  }

  try {
    const payload = JSON.parse(raw);
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
  } catch {
    localStorage.removeItem(key);
  }
}

function downloadDraft(form) {
  const payload = {};
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
  updateSummary(form);
  updateAgeNotice(form);

  form.addEventListener("input", () => {
    saveDraft(form);
    updateSummary(form);
    updateAgeNotice(form);
  });

  form.addEventListener("change", () => {
    saveDraft(form);
    updateSummary(form);
    updateAgeNotice(form);
  });

  form.addEventListener("submit", (event) => {
    const status = form.closest(".form-shell")?.querySelector("[data-form-status]");
    if (!window.siteConfig.formEndpoint) {
      event.preventDefault();
      saveDraft(form);
      updateSummary(form);
      if (status) {
        status.textContent = "No live submission endpoint is configured yet. Your draft is saved on this device. Use Print / Save as PDF or Download entered details for handoff.";
      }
    }
  });

  const saveButton = document.querySelector(form.dataset.saveButton || "");
  if (saveButton) {
    saveButton.addEventListener("click", () => {
      saveDraft(form);
      const status = form.closest(".form-shell")?.querySelector("[data-form-status]");
      if (status) {
        status.textContent = "Draft saved on this device.";
      }
    });
  }

  const downloadButton = document.querySelector(form.dataset.downloadButton || "");
  if (downloadButton) {
    downloadButton.addEventListener("click", () => {
      updateSummary(form);
      downloadDraft(form);
    });
  }

  const printButton = document.querySelector(form.dataset.printButton || "");
  if (printButton) {
    printButton.addEventListener("click", () => {
      updateSummary(form);
      window.print();
    });
  }

  const clearButton = document.querySelector(form.dataset.clearButton || "");
  if (clearButton) {
    clearButton.addEventListener("click", () => {
      form.reset();
      saveDraft(form);
      updateSummary(form);
      updateAgeNotice(form);
    });
  }
}

function initAccessForms() {
  document.querySelectorAll("[data-access-form]").forEach((form) => {
    const role = form.dataset.role;
    const passwordField = form.querySelector('input[type="password"]');
    const status = form.querySelector("[data-access-status]");
    const returnField = form.querySelector('input[name="return_path"]');

    if (!role || !passwordField) {
      return;
    }

    const query = new URLSearchParams(window.location.search);
    if (query.get("role") === role && returnField && !returnField.value && query.get("return")) {
      returnField.value = query.get("return");
    }

    form.addEventListener("submit", (event) => {
      event.preventDefault();
      const expected = window.siteConfig.accessPasswords[role];
      const entered = passwordField.value;

      if (entered === expected) {
        sessionStorage.setItem(`roleAccess:${role}`, "granted");
        const target = returnField?.value || ROLE_ROUTES[role] || "/index.html";
        window.location.href = withBase(target);
        return;
      }

      if (status) {
        status.textContent = "That password did not match.";
      }
    });
  });
}

function initRoleGuards() {
  const role = document.body.dataset.roleGuard;
  if (!role) {
    return;
  }

  if (sessionStorage.getItem(`roleAccess:${role}`) === "granted") {
    return;
  }

  const target = encodeURIComponent(window.location.pathname);
  window.location.href = withBase(`/access/index.html?role=${encodeURIComponent(role)}&return=${target}`);
}

document.addEventListener("DOMContentLoaded", () => {
  initRoleGuards();

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

  document.querySelectorAll("[data-form-endpoint]").forEach((form) => {
    if (window.siteConfig.formEndpoint) {
      form.setAttribute("action", window.siteConfig.formEndpoint);
      form.setAttribute("method", "post");
    }
  });

  document.querySelectorAll("[data-form-status]").forEach((status) => {
    status.textContent = window.siteConfig.formEndpoint
      ? `This form is configured to submit through ${window.siteConfig.formServiceName}.`
      : "No external form endpoint is configured yet. Save a draft locally, print or save as PDF, or download the entered details for manual collection.";
  });

  document.querySelectorAll("[data-contact-label]").forEach((node) => {
    node.textContent = window.siteConfig.volunteerContactLabel;
  });

  document.querySelectorAll("[data-contact-value]").forEach((node) => {
    node.textContent = window.siteConfig.volunteerContactValue;
  });

  document.querySelectorAll("[data-workflow-form]").forEach((form) => {
    initWorkflowForm(form);
  });

  document.querySelectorAll("[data-print-page]").forEach((button) => {
    button.addEventListener("click", () => window.print());
  });

  initAccessForms();
});
