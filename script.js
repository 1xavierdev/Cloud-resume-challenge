document.addEventListener("DOMContentLoaded", () => {
  const el = document.getElementById("visitor-count");
  if (!el) return;

  fetch("https://vtithsrcs9.execute-api.us-east-1.amazonaws.com/count")
    .then((res) => {
      if (!res.ok) throw new Error(`API returned ${res.status}`);
      return res.json();
    })
    .then((data) => {
      el.textContent = data.views;
    })
    .catch((err) => {
      console.error("Visitor counter failed:", err);
      el.textContent = "unavailable";
    });
});
