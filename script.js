const header = document.querySelector("[data-header]");
const menuToggle = document.querySelector("[data-menu-toggle]");
const navLinks = document.querySelectorAll(".nav a");

const setHeaderState = () => {
  if (!header) return;
  header.classList.toggle("is-scrolled", window.scrollY > 18);
};

setHeaderState();
window.addEventListener("scroll", setHeaderState, { passive: true });

if (menuToggle) {
  menuToggle.addEventListener("click", () => {
    const isOpen = document.body.classList.toggle("menu-open");
    menuToggle.setAttribute("aria-expanded", String(isOpen));
  });
}

navLinks.forEach((link) => {
  link.addEventListener("click", () => {
    document.body.classList.remove("menu-open");
    if (menuToggle) {
      menuToggle.setAttribute("aria-expanded", "false");
    }
  });
});

const observer = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("is-visible");
        observer.unobserve(entry.target);
      }
    });
  },
  { threshold: 0.12 }
);

document.querySelectorAll(".reveal").forEach((element) => observer.observe(element));

const riskWidget = document.querySelector("[data-risk-widget]");

if (riskWidget) {
  const intro = riskWidget.querySelector("[data-risk-intro]");
  const startButton = riskWidget.querySelector("[data-risk-start]");
  const form = riskWidget.querySelector("[data-risk-form]");
  const result = riskWidget.querySelector("[data-risk-result]");
  const categoryNode = riskWidget.querySelector("[data-risk-category]");
  const messageNode = riskWidget.querySelector("[data-risk-message]");

  startButton?.addEventListener("click", () => {
    intro.hidden = true;
    form.hidden = false;
    form.querySelector("input, select")?.focus();
  });

  form?.addEventListener("submit", (event) => {
    event.preventDefault();

    const data = new FormData(form);
    const age = Number(data.get("age"));
    const pressure = Number(data.get("pressure"));
    const cholesterol = Number(data.get("cholesterol"));
    const unknownClinicalData = !pressure || !cholesterol;
    let score = 0;

    if (age >= 70) score += 3;
    else if (age >= 55) score += 2;
    else if (age >= 40) score += 1;

    if (data.get("sex") === "male") score += 1;
    if (data.get("smoking") === "current") score += 2;
    if (data.get("smoking") === "recent") score += 1;
    if (pressure >= 180) score += 3;
    else if (pressure >= 160) score += 2;
    else if (pressure >= 140) score += 1;
    if (cholesterol >= 8) score += 3;
    else if (cholesterol >= 6.5) score += 2;
    else if (cholesterol >= 5) score += 1;
    if (data.get("diabetes") === "yes") score += 3;
    if (data.get("family") === "yes") score += 1;

    let category = "низкий";
    if (score >= 8) category = "очень высокий";
    else if (score >= 5) category = "высокий";
    else if (score >= 3) category = "умеренный";

    categoryNode.textContent = `Предварительная категория риска: ${category}`;
    messageNode.textContent = `По предоставленным данным ваша предварительная категория риска: ${category}. Это не диагноз, а ориентировочная оценка. Точная картина требует осмотра и анализов.${unknownClinicalData ? " Так как часть показателей не указана, категорию рекомендуется уточнить после измерения давления и лабораторной оценки липидного обмена." : ""} Чтобы разобраться, что это значит и какие шаги обсудить с врачом, я подготовила гайд по липидному обмену с рекомендациями для вашей категории.`;

    form.hidden = true;
    result.hidden = false;
    result.scrollIntoView({ behavior: "smooth", block: "center" });
  });
}
