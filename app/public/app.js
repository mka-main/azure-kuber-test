const WEEKDAYS = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
const WEEKDAYS_SHORT = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
const MONTHS = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];

function startOfDay(d) {
  return new Date(d.getFullYear(), d.getMonth(), d.getDate());
}

function addDays(d, n) {
  const next = new Date(d);
  next.setDate(next.getDate() + n);
  return startOfDay(next);
}

function mondayOf(d) {
  const copy = startOfDay(d);
  const day = copy.getDay();
  const diff = day === 0 ? -6 : 1 - day;
  copy.setDate(copy.getDate() + diff);
  return startOfDay(copy);
}

function sameDay(a, b) {
  return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
}

const today = startOfDay(new Date());
const weekStart = mondayOf(today);
const week = Array.from({ length: 7 }, (_, i) => addDays(weekStart, i));

let selected = today;

const els = {
  range: document.getElementById("range"),
  status: document.getElementById("status"),
  weekday: document.getElementById("weekday"),
  number: document.getElementById("number"),
  week: document.getElementById("week"),
};

function statusText(d) {
  if (sameDay(d, today)) return "Today";
  const delta = Math.round((d - today) / 86400000);
  if (delta === 1) return "Tomorrow";
  if (delta === -1) return "Yesterday";
  return "";
}

function move(step) {
  const index = week.findIndex((d) => sameDay(d, selected));
  selected = week[(index + step + 7) % 7];
  render();
}

function render() {
  const first = week[0];
  const last = week[6];
  const sameMonth = first.getMonth() === last.getMonth();
  els.range.textContent = sameMonth
    ? `${first.getDate()}–${last.getDate()} ${MONTHS[first.getMonth()]}`
    : `${first.getDate()} ${MONTHS[first.getMonth()]} – ${last.getDate()} ${MONTHS[last.getMonth()]}`;

  els.status.textContent = statusText(selected);
  els.number.textContent = String(selected.getDate());
  els.weekday.textContent = WEEKDAYS[selected.getDay()];

  els.week.replaceChildren();
  week.forEach((d) => {
    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = "day";
    const jsDay = d.getDay();
    if (sameDay(d, today)) btn.classList.add("is-today");
    if (sameDay(d, selected)) btn.classList.add("is-selected");
    const short = WEEKDAYS_SHORT[jsDay === 0 ? 6 : jsDay - 1];
    btn.innerHTML = `<span class="name">${short}</span><span class="num">${d.getDate()}</span>`;
    btn.setAttribute("aria-current", sameDay(d, selected) ? "date" : "false");
    btn.addEventListener("click", () => {
      selected = d;
      render();
    });
    els.week.appendChild(btn);
  });
}

document.getElementById("prev").addEventListener("click", () => move(-1));
document.getElementById("next").addEventListener("click", () => move(1));

window.addEventListener("keydown", (e) => {
  if (e.key === "ArrowLeft") move(-1);
  if (e.key === "ArrowRight") move(1);
});

render();
