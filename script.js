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

  const normalizeNumber = (value) => Number(String(value || "").replace(",", ".").trim());
  const normalizeLipid = (value) => {
    const number = normalizeNumber(value);
    if (!Number.isFinite(number)) return NaN;
    return number > 20 ? Number((number / 38.67).toFixed(2)) : number;
  };
  const isKnownNumber = (value) => Number.isFinite(Number(value));
  const isYes = (value) => value === "yes";
  const formatPercent = (value) => value.toFixed(1).replace(".", ",");

  const calculateScore2Factors = (answers) => {
    const age = Number(answers.age);
    const pressure = Number(answers.systolicPressure);
    const total = Number(answers.totalCholesterol);
    const hdl = Number(answers.hdlCholesterol);
    const nonHdl = isKnownNumber(total) && isKnownNumber(hdl) ? Math.max(total - hdl, 0) : NaN;
    let percent = 0.5;

    if (age >= 70) percent += 4.5;
    else if (age >= 60) percent += 3;
    else if (age >= 50) percent += 1.8;
    else if (age >= 40) percent += 0.8;

    if (answers.sex === "male") percent += 0.8;
    if (answers.smoking === "current") percent += 1.4;
    if (answers.smoking === "recent") percent += 0.6;

    if (pressure >= 180) percent += 2.2;
    else if (pressure >= 160) percent += 1.5;
    else if (pressure >= 140) percent += 0.8;

    if (isKnownNumber(nonHdl)) {
      if (nonHdl >= 5.8) percent += 2;
      else if (nonHdl >= 4.9) percent += 1.4;
      else if (nonHdl >= 3.9) percent += 0.8;
    }

    if (isKnownNumber(hdl) && hdl < 1) percent += 0.6;
    if (isYes(answers.familyHistory)) percent += 0.6;

    percent = Math.max(0.5, Math.min(15, percent));

    let category = "низкий";
    if (percent > 10) category = "очень высокий";
    else if (percent >= 5) category = "высокий";
    else if (percent >= 1) category = "умеренный";

    return { category, percent };
  };

  const getCategoryMeta = (category) => {
    if (category === "очень высокий") {
      return {
        label: "🔴 Очень высокий риск",
        ldlTarget: "<1,4 ммоль/л (<55 мг/дл)",
        actions: [
          "активная коррекция факторов риска",
          "достижение целевых значений LDL (ЛПНП, «плохого» холестерина)",
          "контроль артериального давления",
          "регулярное наблюдение у кардиолога",
          "выполнение индивидуального плана профилактики и лечения"
        ],
        recommendation: "Даже при очень высоком риске своевременная профилактика и современная терапия позволяют значительно снизить вероятность инфаркта, инсульта и других осложнений. Не меняйте текущую терапию самостоятельно."
      };
    }

    if (category === "высокий") {
      return {
        label: "🟠 Высокий риск",
        ldlTarget: "<1,8 ммоль/л (<70 мг/дл)",
        actions: [
          "активная коррекция факторов риска",
          "достижение целевых значений LDL (ЛПНП, «плохого» холестерина)",
          "контроль артериального давления",
          "регулярное наблюдение у кардиолога",
          "обсуждение с врачом необходимости дополнительного обследования и медикаментозной профилактики"
        ],
        recommendation: "Рекомендуется консультация кардиолога для составления индивидуального плана профилактики. Решение о препаратах принимает врач после оценки анамнеза, осмотра и анализов."
      };
    }

    if (category === "умеренный") {
      return {
        label: "🟡 Умеренный риск",
        ldlTarget: "<2,6 ммоль/л (<100 мг/дл)",
        actions: [
          "коррекция питания",
          "снижение веса при избытке массы тела",
          "отказ от курения",
          "контроль давления и липидов",
          "обсуждение с врачом необходимости дополнительного обследования"
        ],
        recommendation: "Умеренный риск — это группа, где профилактика особенно эффективна. На этом этапе часто удаётся предотвратить развитие инфаркта, инсульта и необходимость длительного лечения в будущем."
      };
    }

    return {
      label: "🟢 Низкий риск",
      ldlTarget: "<2,6 ммоль/л (<100 мг/дл)",
      actions: [
        "поддерживать здоровый образ жизни",
        "контролировать давление, холестерин и вес",
        "поддерживать регулярную физическую активность не менее 150 минут в неделю",
        "не курить",
        "проходить профилактические обследования"
      ],
      recommendation: "Низкий риск сегодня не гарантирует низкий риск в будущем, поэтому важно продолжать профилактику."
    };
  };

  const calculateRisk = (answers) => {
    const ldl = Number(answers.ldlCholesterol);
    const score = calculateScore2Factors(answers);
    let category = score.category;

    if (isYes(answers.ascvd)) category = "очень высокий";
    else if ((isKnownNumber(ldl) && ldl >= 4.9) || isYes(answers.ckd) || isYes(answers.diabetes) || isYes(answers.familyHistory)) {
      category = "высокий";
    }

    return {
      category,
      meta: getCategoryMeta(category),
      score,
      ldlKnown: isKnownNumber(ldl),
      hasUnknownData: !isKnownNumber(answers.systolicPressure) || !isKnownNumber(answers.totalCholesterol) || !isKnownNumber(answers.hdlCholesterol)
    };
  };

  form?.addEventListener("submit", (event) => {
    event.preventDefault();

    const data = new FormData(form);
    const answers = {
      age: normalizeNumber(data.get("age")),
      sex: data.get("sex"),
      smoking: data.get("smoking"),
      systolicPressure: normalizeNumber(data.get("systolicPressure")),
      ascvd: data.get("ascvd"),
      diabetes: data.get("diabetes"),
      ckd: data.get("ckd"),
      familyHistory: data.get("familyHistory"),
      totalCholesterol: normalizeLipid(data.get("totalCholesterol")),
      hdlCholesterol: normalizeLipid(data.get("hdlCholesterol")),
      ldlCholesterol: normalizeLipid(data.get("ldlCholesterol"))
    };
    const { meta, score, ldlKnown, hasUnknownData } = calculateRisk(answers);
    const people = Math.max(1, Math.round(score.percent));
    const unknownNote = hasUnknownData
      ? "\n\nТак как часть показателей не указана, результат является предварительным. Точную категорию рекомендуется уточнить после измерения давления и лабораторной оценки липидного обмена."
      : "";

    categoryNode.textContent = "";
    categoryNode.hidden = true;
    messageNode.textContent =
      `Ваш 10-летний сердечно-сосудистый риск по SCORE2 составляет: ${formatPercent(score.percent)}%\n\n` +
      `Это означает вероятность развития инфаркта миокарда, инсульта или другого серьёзного сердечно-сосудистого события в течение ближайших 10 лет. Примерно у ${people} из 100 людей с аналогичными факторами риска в течение ближайших 10 лет может развиться такое осложнение.\n\n` +
      `Что делать:\n- ${meta.actions.join("\n- ")}\n\n` +
      `Рекомендация:\n${meta.recommendation}` +
      `${ldlKnown ? "" : "\n\nLDL (ЛПНП, «плохой» холестерин) не указан, поэтому целевой уровень показан по категории риска."}` +
      `${unknownNote}\n\nЭто не диагноз и не индивидуальное назначение лечения. Точная картина требует консультации врача, осмотра и анализов.`;

    form.hidden = true;
    result.hidden = false;
    result.scrollIntoView({ behavior: "smooth", block: "center" });
  });
}
