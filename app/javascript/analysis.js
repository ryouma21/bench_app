document.addEventListener("turbo:load", () => {
  // 🔽 data属性を持つ要素を取得
  const chartEl = document.getElementById("chart-data");
  if (!chartEl) return;
  // 🔽 Railsから渡されたJSON文字列を配列に変換
  const oneRmValues = JSON.parse(chartEl.dataset.values);
  const oneRmDates  = JSON.parse(chartEl.dataset.dates);

  const ctx = document.getElementById("oneRmChart");
  if (!ctx) return;

  new Chart(ctx, {
    type: 'line',
    data: {
      labels: oneRmDates,
      datasets: [{
        label: '推定1RM',
        data: oneRmValues,
        borderColor: 'rgba(255,159,64,1)',
        borderWidth: 2,
        tension: 0.3,
        fill: false
      }]
    }
  });
});
