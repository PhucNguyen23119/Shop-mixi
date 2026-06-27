document.addEventListener("DOMContentLoaded", () => {
  const variantsInput = document.getElementById("variantsInput");
  const colorsInput = document.getElementById("colorsInput");

  const variantRows = document.getElementById("variantRows");
  const colorRows = document.getElementById("colorRows");

  const addVariantBtn = document.getElementById("addVariantBtn");
  const addColorBtn = document.getElementById("addColorBtn");

  if (!variantsInput || !colorsInput || !variantRows || !colorRows) {
    console.log("Không tìm thấy form dynamic admin.");
    return;
  }

  function createVariantRow(data = {}) {
    const row = document.createElement("div");
    row.className = "dynamic-row variant-row";

    row.innerHTML = `
      <div>
        <label>Bộ nhớ</label>
        <input class="variant-storage" placeholder="256GB" value="${data.storage || ""}">
      </div>

      <div>
        <label>RAM</label>
        <input class="variant-ram" placeholder="8GB RAM" value="${data.ram || ""}">
      </div>

      <div>
        <label>Giá bán</label>
        <input class="variant-price" placeholder="29990000" value="${data.price || ""}">
      </div>

      <div>
        <label>Giá cũ</label>
        <input class="variant-old-price" placeholder="34990000" value="${data.oldPrice || ""}">
      </div>

      <button type="button" class="admin-mini-btn red remove-row-btn">Xóa</button>
    `;

    row.querySelector(".remove-row-btn").addEventListener("click", () => {
      row.remove();
    });

    variantRows.appendChild(row);
  }

  function createColorRow(data = {}) {
    const row = document.createElement("div");
    row.className = "dynamic-color-card";

    row.innerHTML = `
      <div class="dynamic-row color-main-row">
        <div>
          <label>Tên màu</label>
          <input class="color-name" placeholder="Xám" value="${data.name || ""}">
        </div>

        <div>
          <label>Mã màu</label>
          <input class="color-code" placeholder="#999999" value="${data.code || ""}">
        </div>

        <div>
          <label>Ảnh chính</label>
          <input class="color-main-image" placeholder="/static/img/product.jpg" value="${data.mainImage || ""}">
        </div>

        <button type="button" class="admin-mini-btn red remove-row-btn">Xóa</button>
      </div>

      <div class="gallery-box">
        <label>Ảnh gallery</label>
        <textarea class="color-gallery" rows="4" placeholder="Mỗi link ảnh nhập 1 dòng">${data.gallery || ""}</textarea>
      </div>
    `;

    row.querySelector(".remove-row-btn").addEventListener("click", () => {
      row.remove();
    });

    colorRows.appendChild(row);
  }

  function loadVariants() {
    const text = variantsInput.value.trim();

    if (!text) {
      createVariantRow();
      return;
    }

    text.split("\n").forEach((line) => {
      const parts = line.split("|").map((item) => item.trim());

      createVariantRow({
        storage: parts[0] || "",
        ram: parts[1] || "",
        price: parts[2] || "",
        oldPrice: parts[3] || "",
      });
    });
  }

  function loadColors() {
    const text = colorsInput.value.trim();

    if (!text) {
      createColorRow();
      return;
    }

    text.split("\n").forEach((line) => {
      const parts = line.split("|").map((item) => item.trim());

      const gallery = parts[3]
        ? parts[3]
            .split(",")
            .map((img) => img.trim())
            .join("\n")
        : "";

      createColorRow({
        name: parts[0] || "",
        code: parts[1] || "",
        mainImage: parts[2] || "",
        gallery: gallery,
      });
    });
  }

  function syncVariants() {
    const rows = variantRows.querySelectorAll(".variant-row");

    const lines = Array.from(rows)
      .map((row) => {
        const storage = row.querySelector(".variant-storage").value.trim();
        const ram = row.querySelector(".variant-ram").value.trim();
        const price = row.querySelector(".variant-price").value.trim();
        const oldPrice = row.querySelector(".variant-old-price").value.trim();

        if (!storage || !ram || !price) return "";

        if (oldPrice) {
          return `${storage} | ${ram} | ${price} | ${oldPrice}`;
        }

        return `${storage} | ${ram} | ${price}`;
      })
      .filter(Boolean);

    variantsInput.value = lines.join("\n");
  }

  function syncColors() {
    const rows = colorRows.querySelectorAll(".dynamic-color-card");

    const lines = Array.from(rows)
      .map((row) => {
        const name = row.querySelector(".color-name").value.trim();
        const code = row.querySelector(".color-code").value.trim();
        const mainImage = row.querySelector(".color-main-image").value.trim();

        const galleryImages = row
          .querySelector(".color-gallery")
          .value.split("\n")
          .map((img) => img.trim())
          .filter(Boolean);

        if (!name || !code || !mainImage) return "";

        if (galleryImages.length > 0) {
          return `${name} | ${code} | ${mainImage} | ${galleryImages.join(", ")}`;
        }

        return `${name} | ${code} | ${mainImage}`;
      })
      .filter(Boolean);

    colorsInput.value = lines.join("\n");
  }

  addVariantBtn.addEventListener("click", () => {
    createVariantRow();
  });

  addColorBtn.addEventListener("click", () => {
    createColorRow();
  });

  const form = variantsInput.closest("form");

  if (form) {
    form.addEventListener("submit", () => {
      syncVariants();
      syncColors();
    });
  }

  loadVariants();
  loadColors();
});
