// =========================
// API / SQL CONFIG
// =========================

// Sau này bạn của bạn thêm link API SQL vào đây
const API_URL = "/api/products";

function normalizeImagePath(path) {
  if (!path) return "";
  if (/^(https?:)?\/\//.test(path) || path.startsWith("/static/")) return path;
  return (
    "/static/img/" +
    path
      .replace(/^\.\.\/images\//, "")
      .replace(/^images\//, "")
      .replace(/^\/images\//, "")
  );
}

function normalizeGallery(gallery) {
  return (gallery || []).map(normalizeImagePath);
}

// =========================
// TEMP DATA - dùng tạm khi chưa có SQL
// =========================

// const allProducts = [
//   {
//     id: 1,
//     name: "iPhone 17e",
//     category: "phone",
//     brand: "Apple",
//     desc: "Pro đỉnh cao.",

//     defaultStorageIndex: 0,
//     defaultColorIndex: 0,

//     oldPrice: "39.000.000 đ",
//     discount: "-10%",
//     hasDiscount: true,

//     rating: 4.9,
//     sold: 371,

//     isFlashSale: true,
//     isFeatured: true,
//     isNew: true,

//     technicalImage: "images/iphone-17e-note.jpg",

//     storages: [
//       {
//         storage: "256 GB",
//         ram: "8 GB",
//         price: "34.990.000 đ",
//         priceNumber: 34990000,
//       },
//       {
//         storage: "512 GB",
//         ram: "8 GB",
//         price: "39.990.000 đ",
//         priceNumber: 39990000,
//       },
//       {
//         storage: "1 TB",
//         ram: "8 GB",
//         price: "45.990.000 đ",
//         priceNumber: 45990000,
//       },
//     ],

//     colors: [
//       {
//         name: "Hồng",
//         code: "#ffc2e9",
//         image: "images/iPhone_17e_7.webp",
//         gallery: [
//           "images/iPhone_17e_7.webp",
//           "images/iphone-17e-pink1.jpg",
//           "images/iphone-17e-pink2.jpg",
//           "images/iphone-17e-pink3.jpg",
//         ],
//       },
//       {
//         name: "Đen",
//         code: "#000000",
//         image: "images/iPhone_17e-2_2.webp",
//         gallery: [
//           "images/iPhone_17e-2_2.webp",
//           "images/iphone-17e-black-2-639081454471266575-750x500.jpg",
//           "images/iphone-17e-black-3-639081454477150583-750x500.jpg",
//           "images/iphone-17e-black1.jpg",
//         ],
//       },
//       {
//         name: "Trắng",
//         code: "#ffffff",
//         image: "images/iPhone_17e-2-2_2.webp",
//         gallery: ["images/iPhone_17e-2-2_2.webp"],
//       },
//     ],

//     fullSpecifications: [
//       {
//         title: "Màn hình",
//         items: [
//           { label: "Kích thước màn hình", value: "6.1 inch" },
//           { label: "Công nghệ màn hình", value: "Super Retina XDR OLED" },
//           { label: "Độ phân giải", value: "2532 x 1170 pixels" },
//           {
//             label: "Tính năng màn hình",
//             value: "HDR10, Dolby Vision, Always-on display",
//           },
//           { label: "Tần số quét", value: "120Hz" },
//           { label: "Kiểu màn hình", value: "IPS LCD" },
//         ],
//       },
//       {
//         title: "Camera",
//         items: [
//           { label: "Camera sau", value: "12MP, chống rung quang học OIS" },
//           { label: "Camera trước", value: "12MP, khẩu độ f/1.9" },
//           { label: "Quay video", value: "4K@30fps, Full HD 1080p" },
//           {
//             label: "Tính năng camera",
//             value: "HDR, lấy nét tự động, panorama, chống rung điện tử",
//           },
//         ],
//       },
//       {
//         title: "Vi xử lý & đồ họa",
//         items: [
//           { label: "Chipset", value: "Apple A15 Bionic" },
//           { label: "GPU", value: "Apple GPU" },
//         ],
//       },
//       {
//         title: "Giao tiếp & kết nối",
//         items: [
//           { label: "Công nghệ NFC", value: "Không" },
//           { label: "Thẻ SIM", value: "1 Nano-SIM" },
//           { label: "GPS", value: "A-GPS, GLONASS" },
//         ],
//       },
//       {
//         title: "RAM & Bộ nhớ",
//         items: [
//           { label: "RAM", value: "{ram}" },
//           { label: "Bộ nhớ trong", value: "{storage}" },
//         ],
//       },
//       {
//         title: "Hệ điều hành",
//         items: [{ label: "Hệ điều hành", value: "iOS 10" }],
//       },
//       {
//         title: "Kích thước & trọng lượng",
//         items: [
//           { label: "Kích thước", value: "138.3 x 67.1 x 7.1 mm" },
//           { label: "Trọng lượng", value: "138 g" },
//         ],
//       },
//       {
//         title: "Kháng nước",
//         items: [{ label: "Chỉ số kháng nước", value: "IP68" }],
//       },
//       {
//         title: "Pin & sạc",
//         items: [
//           { label: "Dung lượng pin", value: "5960 mAh" },
//           { label: "Công nghệ sạc", value: "Sạc tiêu chuẩn 100W" },
//         ],
//       },
//       {
//         title: "Cảm biến & tính năng đặc biệt",
//         items: [
//           {
//             label: "Cảm biến",
//             value:
//               "Cảm biến vân tay, cảm biến gia tốc, cảm biến tiệm cận, cảm biến ánh sáng, la bàn, con quay hồi chuyển",
//           },
//           {
//             label: "Tính năng đặc biệt",
//             value:
//               "Mở khóa nhanh, quay video 4K, chống rung quang học, thiết kế nhỏ gọn, kháng nước kháng bụi",
//           },
//           { label: "Cổng sạc", value: "Lightning" },
//         ],
//       },
//       {
//         title: "Kết nối",
//         items: [
//           { label: "Tương thích mạng", value: "4G LTE" },
//           { label: "Công nghệ Wifi", value: "Wi-Fi 5" },
//           { label: "Bluetooth", value: "Bluetooth 4.2" },
//           { label: "Thẻ nhớ", value: "Không hỗ trợ" },
//         ],
//       },
//       {
//         title: "Thiết kế & hoàn thiện",
//         items: [
//           { label: "Vật liệu khung", value: "Khung nhôm nguyên khối" },
//           { label: "Mặt lưng", value: "Nhôm" },
//         ],
//       },
//       {
//         title: "Thông tin chung",
//         items: [{ label: "Thời điểm ra mắt", value: "2016-09-16" }],
//       },
//     ],

//     reviews: [
//       {
//         user: "Phúc Nguyễn",
//         rating: 1,
//         comment: "Máy chơi game chưa ổn định, đôi lúc bị drop FPS.",
//       },
//       {
//         user: "Cường Văn Nguyễn",
//         rating: 5,
//         comment: "Máy dùng khá mượt, thiết kế đẹp, đáng mua.",
//       },
//       {
//         user: "Luân Hồng",
//         rating: 5,
//         comment: "Giao diện đẹp, chức năng ổn, trải nghiệm tốt.",
//       },
//       {
//         user: "Nguyễn Phát",
//         rating: 5,
//         comment: "Sản phẩm tốt, phù hợp với nhu cầu sử dụng hằng ngày.",
//       },
//     ],
//   },
// ];
//   {
//     id: 2,
//     name: "MacBook Air",
//     category: "laptop",
//     brand: "Apple",
//     desc: "Mỏng nhẹ, hiệu năng mạnh mẽ.",
//     price: "28.990.000 đ",
//     priceNumber: 28990000,
//     oldPrice: "32.000.000 đ",
//     technicalImage: "images/macbook-note.jpg",
//     storage: "512GB",
//     specs: ["M3", "16GB"],
//     image: "images/macbook.png",
//     rating: 4.8,
//     sold: 221,
//     discount: "-15%",
//     hasDiscount: true,
//     isFlashSale: true,
//     isFeatured: true,
//     isNew: false,
//   },
//   {
//     id: 3,
//     name: "Samsung Galaxy S26 Ultra",
//     category: "phone",
//     brand: "Samsung",
//     desc: "Camera đẳng cấp, AI thông minh.",
//     price: "29.990.000 đ",
//     priceNumber: 29990000,
//     oldPrice: "34.990.000 đ",
//     storages: [
//       {
//         storage: "256 GB",
//         price: "29.990.000 đ",
//         priceNumber: 29990000,
//       },
//       {
//         storage: "512 GB",
//         price: "34.990.000 đ",
//         priceNumber: 34990000,
//       },
//       {
//         storage: "1 TB",
//         price: "39.990.000 đ",
//         priceNumber: 39990000,
//       },
//     ],
//     colors: [
//       {
//         name: "Đen",
//         code: "#000000",
//         image: "../images/samsung-galaxy-s26-ultra-black-1.jpg",

//         gallery: [
//           "../images/samsung-galaxy-s26-ultra-black-1.jpg",
//           "../images/samsung-galaxy-s26-ultra-black-2.jpg",
//           "../images/samsung-galaxy-s26-ultra-black-3.jpg",
//           "../images/samsung-galaxy-s26-ultra-black-4.jpg",
//           "../images/samsung-galaxy-s26-ultra-bbh.jpg",
//         ],
//       },

//       {
//         name: "Xanh Dương",

//         code: "#037dff",
//         image: "../images/samsung-galaxy-s26-ultra-blue-1.jpg",

//         gallery: [
//           "../images/samsung-galaxy-s26-ultra-blue-1.jpg",
//           "../images/samsung-galaxy-s26-ultra-blue-2.jpg",
//           "../images/samsung-galaxy-s26-ultra-blue-3.jpg",
//           "../images/samsung-galaxy-s26-ultra-bbh.jpg",
//         ],
//       },

//       {
//         name: "Tím",
//         code: "#91008a",
//         image: "../images/samsung-galaxy-s26-ultra-purple-1.jpg",

//         gallery: [
//           "../images/samsung-galaxy-s26-ultra-purple-1.jpg",
//           "../images/samsung-galaxy-s26-ultra-purple-2.jpg",
//           "../images/samsung-galaxy-s26-ultra-purple-3.jpg",
//           "../images/samsung-galaxy-s26-ultra-purple-4.jpg",
//           "../images/samsung-galaxy-s26-ultra-bbh.jpg",
//         ],
//       },
//     ],
//     specs: ["512GB", "12GB RAM"],
//     image: "images/samsung-galaxy-s26-ultra-black-1.jpg",
//     technicalImage: "images/samsung-galaxy-s26-ultra-note.jpg",
//     rating: 4.8,
//     sold: 245,
//     discount: "-14%",
//     hasDiscount: true,
//     isFlashSale: false,
//     isFeatured: true,
//     isNew: true,
//   },
//   {
//     id: 4,
//     name: "ASUS Zenbook DUO",
//     category: "laptop",
//     brand: "ASUS",
//     desc: "Điều tuyệt diệu của Asus ở mức giá bất ngờ.",
//     price: "157.499.000 đ",
//     priceNumber: 157499000,
//     storage: "1TB",
//     oldPrice: "165.000.000 đ",
//     specs: ["OLED", "32GB RAM"],
//     image: "images/zenbook.png",
//     rating: 4.9,
//     sold: 86,
//     discount: "-5%",
//     hasDiscount: true,
//     isFlashSale: false,
//     isFeatured: true,
//     isNew: true,
//   },
//   {
//     id: 5,
//     name: "Bose QuietComfort Ultra Earbuds",
//     category: "audio",
//     brand: "Bose",
//     desc: "Thể hiện niềm tự tin trong bạn.",
//     price: "6.990.000 đ",
//     priceNumber: 6990000,
//     oldPrice: "8.000.000 đ",
//     specs: ["ANC", "Bluetooth"],
//     image: "images/bose.png",
//     rating: 4.7,
//     sold: 156,
//     discount: "-12%",
//     hasDiscount: true,
//     isFlashSale: false,
//     isFeatured: true,
//     isNew: true,
//   },
// ];
function normalizeProduct(product) {
  const defaultStorage = product.storages?.[product.defaultStorageIndex || 0];

  const defaultColor = product.colors?.[product.defaultColorIndex || 0];

  return {
    ...product,
    colors: (product.colors || []).map((color) => ({
      ...color,
      image: normalizeImagePath(color.image),
      gallery: normalizeGallery(color.gallery),
    })),

    price: product.price || defaultStorage?.price || "",
    priceNumber: product.priceNumber || defaultStorage?.priceNumber || 0,

    image: normalizeImagePath(product.image || defaultColor?.image || ""),

    gallery: normalizeGallery(
      product.gallery ||
        defaultColor?.gallery ||
        (defaultColor?.image ? [defaultColor.image] : []),
    ),

    specs:
      product.specs ||
      [
        defaultStorage?.storage?.replace(" ", ""),
        defaultStorage?.ram ? `${defaultStorage.ram} RAM` : "",
      ].filter(Boolean),

    isFlashSale: Boolean(product.isFlashSale),
    isFeatured: Boolean(product.isFeatured),
    isNew: Boolean(product.isNew),
    hasDiscount: Boolean(product.hasDiscount),
  };
}

function normalizeProducts(products) {
  return products.map(normalizeProduct);
}
// =========================
// FETCH DATA FROM SQL/API
// =========================

async function getProducts() {
  if (!API_URL) {
    return normalizeProducts(allProducts);
  }

  try {
    const response = await fetch(API_URL);
    const data = await response.json();

    return normalizeProducts(data);
  } catch (error) {
    console.error("Lỗi tải dữ liệu sản phẩm:", error);
    return normalizeProducts(allProducts);
  }
}
// =========================
// RENDER CARD CHUNG
// =========================

function renderProductCard(product) {
  return `
        <article
            class="flash-card"
            onclick="window.location.href='/detail?id=${product.id}'"
        >

            <div class="badge-group">

                ${product.isNew ? `<span class="new">New</span>` : ""}

                ${
                  product.hasDiscount
                    ? `
                        <span class="discount">
                            ${product.discount}
                        </span>
                    `
                    : ""
                }

            </div>

            <figure class="image-box">
                <img
                    class="product-img"
                    src="${product.image}"
                    alt="${product.name}"
                >
            </figure>

            <div class="specs">
                ${product.specs.map((spec) => `<span>${spec}</span>`).join("")}
            </div>

            <h3>${product.name}</h3>

            <p class="rating">
                ⭐ ${product.rating}
                • Đã bán ${product.sold}
            </p>

            <p class="price">
                ${product.price}
            </p>

            ${
              product.hasDiscount
                ? `
                    <div class="old-price">
                        <span>
                            ${product.oldPrice}
                        </span>

                        <span class="sale-off">
                            ${product.discount}
                        </span>
                    </div>
                `
                : ""
            }

        </article>
    `;
}

function renderNewCard(product) {
  return `
        <article
            class="new-card"
            onclick="window.location.href='/detail?id=${product.id}'"
        >
            <span class="new-badge">MỚI</span>

            <h3>${product.name}</h3>

            <p>${product.desc}</p>

            <span class="card-price">${product.price}</span>

            <img src="${product.image}" alt="${product.name}">
        </article>
    `;
}

// =========================
// RENDER SECTION
// =========================

async function renderPage() {
  const products = await getProducts();

  const flashProducts = products.filter((product) => product.isFlashSale);

  const featuredProducts = products.filter((product) => product.isFeatured);

  const newProducts = products.filter((product) => product.isNew);

  const flashContainer = document.querySelector(".flash-products");

  const featuredContainer = document.querySelector(".featured-products");

  const newGenContainer = document.querySelector(".new-gen-list");

  const allProductsContainer = document.querySelector(".all-products");

  const productsTitle = document.querySelector(".products-title");

  const brandTabs = document.querySelector(".brand-tabs");

  // HOME PAGE

  if (flashContainer) {
    flashContainer.innerHTML = flashProducts.map(renderProductCard).join("");
  }

  if (featuredContainer) {
    featuredContainer.innerHTML = featuredProducts
      .map(renderProductCard)
      .join("");
  }

  if (newGenContainer) {
    newGenContainer.innerHTML = newProducts.map(renderNewCard).join("");
  }

  // PRODUCTS PAGE

  const categoryNames = {
    phone: "Điện thoại",
    tablet: "Máy tính bảng",
    laptop: "Laptop",
    ipad: "iPad",
    audio: "Tai nghe",
    accessory: "Phụ kiện",
    watch: "Đồng hồ",
    printer: "Màn hình, máy in",
  };

  const categoryBrands = {
    phone: ["Apple", "Samsung", "Xiaomi", "Oppo", "Realme"],
    tablet: ["Apple", "Samsung", "Xiaomi", "Lenovo"],
    laptop: ["Apple", "ASUS", "Dell", "Lenovo", "HP"],
    ipad: ["Apple"],
    audio: ["Apple", "Bose", "Sony", "JBL"],
    accessory: ["Apple", "Samsung", "Anker", "Ugreen"],
    watch: ["Apple", "Samsung", "Garmin"],
    printer: ["Dell", "HP", "Canon", "Epson"],
  };

  if (allProductsContainer) {
    const params = new URLSearchParams(window.location.search);

    const category = params.get("category");

    const brand = params.get("brand");

    let filteredProducts = products;

    if (category) {
      filteredProducts = products.filter(
        (product) => product.category === category,
      );
    }
    if (brand) {
      filteredProducts = filteredProducts.filter(
        (product) => product.brand === brand,
      );
    }
    if (productsTitle) {
      productsTitle.innerText = category
        ? categoryNames[category]
        : "Tất cả sản phẩm";
    }

    let currentProducts = filteredProducts;

    function applyFilters() {
      let result = [...currentProducts];

      let minPrice = Number(document.getElementById("min-price")?.value || 0);

      let maxPrice = Number(
        document.getElementById("max-price")?.value || 999999999,
      );

      console.log("min:", minPrice);
      console.log("max:", maxPrice);

      if (minPrice > maxPrice) {
        const temp = minPrice;
        minPrice = maxPrice;
        maxPrice = temp;
      }

      const checkedStorages = [
        ...document.querySelectorAll(".capacity-check:checked"),
      ].map((input) => input.value);

      result = result.filter(
        (product) =>
          product.priceNumber >= minPrice && product.priceNumber <= maxPrice,
      );

      if (checkedStorages.length > 0) {
        result = result.filter(
          (product) =>
            product.storages?.some((item) =>
              checkedStorages.some((value) => item.storage.includes(value)),
            ) ||
            checkedStorages.some((value) => product.storage?.includes(value)),
        );
      }

      const sortValue =
        document.querySelector(".sort-select")?.value || "recommend";

      if (sortValue === "price-asc") {
        result.sort((a, b) => a.priceNumber - b.priceNumber);
      }

      if (sortValue === "price-desc") {
        result.sort((a, b) => b.priceNumber - a.priceNumber);
      }
      console.log("currentProducts:", currentProducts);
      console.log("result sau filter:", result);
      allProductsContainer.innerHTML = result.map(renderProductCard).join("");
    }

    // BRAND BUTTONS

    if (brandTabs) {
      const brands = category
        ? categoryBrands[category]
        : ["Apple", "Samsung", "ASUS", "Dell"];

      brandTabs.innerHTML = brands
        .map(
          (brand) => `
                <button
                    type="button"
                    class="brand-filter-btn"
                    data-brand="${brand}"
                >
                    ${brand}
                </button>
            `,
        )
        .join("");

      const brandButtons = document.querySelectorAll(".brand-filter-btn");

      brandButtons.forEach((button) => {
        button.addEventListener("click", () => {
          const brand = button.dataset.brand;

          currentProducts = filteredProducts.filter(
            (product) => product.brand === brand,
          );

          applyFilters();
        });
      });
    }

    // FILTER BUTTON

    document
      .querySelector(".apply-filter-btn")
      ?.addEventListener("click", applyFilters);

    // SORT SELECT

    document
      .querySelector(".sort-select")
      ?.addEventListener("change", applyFilters);

    // RENDER FIRST TIME

    applyFilters();
  }

  initSliders();
  initCountdown();
  initPriceSlider();
}

// =========================
// SLIDERS
// =========================

function initSliders() {
  setupSlider(".flash-products", ".prev-btn", ".next-btn", 260);

  setupSlider(".new-gen-list", ".new-prev-btn", ".new-next-btn", 340);
}

function setupSlider(containerSelector, prevSelector, nextSelector, distance) {
  const container = document.querySelector(containerSelector);
  const prevBtn = document.querySelector(prevSelector);
  const nextBtn = document.querySelector(nextSelector);

  if (!container || !prevBtn || !nextBtn) {
    return;
  }

  nextBtn.addEventListener("click", () => {
    container.scrollBy({
      left: distance,
      behavior: "auto",
    });
  });

  prevBtn.addEventListener("click", () => {
    container.scrollBy({
      left: -distance,
      behavior: "smooth",
    });
  });
}

// =========================
// COUNTDOWN
// =========================

function initCountdown() {
  const countdown = document.getElementById("countdown");

  if (!countdown) {
    return;
  }

  let time = 4 * 60 * 60;

  setInterval(() => {
    let hours = Math.floor(time / 3600);
    let minutes = Math.floor((time % 3600) / 60);
    let seconds = time % 60;

    countdown.innerText = `${hours}h ${minutes}m ${seconds}s`;

    if (time > 0) {
      time--;
    }
  }, 1000);
}

// =========================
// START APP
// =========================

function initPriceSlider() {
  const minSlider = document.getElementById("min-price");

  const maxSlider = document.getElementById("max-price");

  const minText = document.getElementById("min-price-text");

  const maxText = document.getElementById("max-price-text");

  if (!minSlider || !maxSlider) {
    return;
  }

  function formatPrice(number) {
    return Number(number).toLocaleString("vi-VN");
  }

  function updatePrice() {
    minText.innerText = formatPrice(minSlider.value);

    maxText.innerText = formatPrice(maxSlider.value);
  }

  minSlider.addEventListener("input", () => {
    if (Number(minSlider.value) > Number(maxSlider.value)) {
      minSlider.value = maxSlider.value;
    }

    updatePrice();
  });

  maxSlider.addEventListener("input", () => {
    if (Number(maxSlider.value) < Number(minSlider.value)) {
      maxSlider.value = minSlider.value;
    }

    updatePrice();
  });
}
// =========================
// DETAIL PAGE
// =========================

async function renderDetailPage() {
  const detailPage = document.querySelector(".detail-page");

  if (!detailPage) {
    return;
  }

  const products = await getProducts();

  const params = new URLSearchParams(window.location.search);

  const idParam = params.get("id");

  let product = null;

  if (idParam) {
    product = products.find((item) => item.id === Number(idParam));
  }

  /* Nếu mở detail.html mà không có ?id=...
    thì tự động lấy sản phẩm đầu tiên */
  if (!product) {
    product = products[0];

    const newUrl = `/detail?id=${product.id}`;

    window.history.replaceState(null, "", newUrl);
  }
  let selectedStorage = product.storages ? product.storages[0] : null;

  let selectedColor = product.colors ? product.colors[0] : null;

  let currentImageIndex = 0;

  function getFullSpecifications() {
    if (!product.fullSpecifications) {
      return [];
    }

    const ramValue = selectedStorage?.ram || "";

    const storageValue = selectedStorage?.storage || "";

    return product.fullSpecifications.map((group) => ({
      title: group.title,

      items: group.items.map((item) => ({
        label: item.label,
        value: item.value
          .replace("{storage}", storageValue)
          .replace("{ram}", ramValue),
      })),
    }));
  }

  function getSummarySpecifications() {
    const importantLabels = [
      "Kích thước màn hình",
      "Công nghệ màn hình",
      "Camera sau",
      "Camera trước",
      "Chipset",
      "Bộ nhớ trong",
    ];

    const fullSpecs = getFullSpecifications();

    for (const group of fullSpecs) {
      for (const item of group.items) {
        if (labels.includes(item.label)) {
          return item.value;
        }
      }
    }

    return "Đang cập nhật";
  }

  function renderHighlightSpecs() {
    if (highlightScreenSize) {
      highlightScreenSize.textContent = getSpecValueByLabels([
        "Kích thước màfunction getSpecValueByLabels(labels) {n hình",
        "Màn hình",
        "Screen size",
      ]);
    }

    if (highlightChipset) {
      highlightChipset.textContent = getSpecValueByLabels([
        "Chipset",
        "CPU",
        "Chip xử lý",
        "Vi xử lý",
      ]);
    }
  }

  function normalizeText(text) {
    return String(text || "")
      .toLowerCase()
      .trim();
  }

  function getSpecValueByLabels(labels) {
    const fullSpecs = getFullSpecifications();

    const normalizedLabels = labels.map((text) =>
      String(text || "")
        .toLowerCase()
        .trim(),
    );

    for (const group of fullSpecs) {
      for (const item of group.items) {
        const itemLabel = String(item.label || "")
          .toLowerCase()
          .trim();

        const isMatched = normalizedLabels.some((label) => {
          return itemLabel === label || itemLabel.includes(label);
        });

        if (isMatched) {
          return item.value;
        }
      }
    }

    return "Đang cập nhật";
  }

  function renderHighlightSpecs() {
    if (highlightScreenSize) {
      highlightScreenSize.textContent = getSpecValueByLabels([
        "kích thước màn hình",
      ]);
    }

    if (highlightChipset) {
      highlightChipset.textContent = getSpecValueByLabels([
        "chipset",
        "cpu",
        "chip xử lý",
        "vi xử lý",
        "bộ xử lý",
      ]);
    }
  }

  function getSummarySpecifications() {
    const importantLabels = [
      "Kích thước màn hình",
      "Công nghệ màn hình",
      "Camera sau",
      "Camera trước",
      "Chipset",
      "Bộ nhớ trong",
    ];

    const fullSpecs = getFullSpecifications();

    return importantLabels
      .map((label) => {
        for (const group of fullSpecs) {
          const found = group.items.find((item) => item.label === label);

          if (found) {
            return found;
          }
        }

        return null;
      })
      .filter(Boolean);
  }

  function renderSpecs() {
    if (!specTable) {
      return;
    }

    specTable.innerHTML = getSummarySpecifications()
      .map(
        (spec) => `
            <tr>
                <td>${spec.label}</td>
                <td>${spec.value}</td>
            </tr>
        `,
      )
      .join("");
  }
  function renderStars(rating) {
    let stars = "";

    for (let i = 1; i <= 5; i++) {
      stars += i <= rating ? "★" : "☆";
    }

    return stars;
  }

  function renderReviews() {
    const reviews = product.reviews || [];

    if (
      !reviewAverage ||
      !reviewCount ||
      !reviewStars ||
      !reviewBars ||
      !commentTitle ||
      !reviewList ||
      !reviewPagination
    ) {
      return;
    }

    const totalReviews = reviews.length;

    if (totalReviews === 0) {
      reviewAverage.textContent = "0/5";
      reviewCount.textContent = "0 lượt đánh giá";
      reviewStars.textContent = "☆☆☆☆☆";
      commentTitle.textContent = "0 Bình luận";
      reviewBars.innerHTML = "";
      reviewList.innerHTML = "<p>Chưa có đánh giá nào.</p>";
      reviewPagination.innerHTML = "";
      return;
    }

    const totalRating = reviews.reduce((sum, review) => {
      return sum + review.rating;
    }, 0);

    const average = totalRating / totalReviews;

    reviewAverage.textContent = `${average.toFixed(1)}/5`;
    reviewCount.textContent = `${totalReviews} lượt đánh giá`;
    reviewStars.textContent = renderStars(Math.round(average));

    reviewBars.innerHTML = [5, 4, 3, 2, 1]
      .map((star) => {
        const count = reviews.filter((review) => review.rating === star).length;

        const percent = totalReviews > 0 ? (count / totalReviews) * 100 : 0;

        return `
            <div class="review-bar-row">
                <span>${star} ★</span>

                <div class="review-bar">
                    <div style="width: ${percent}%"></div>
                </div>

                <small>${count} đánh giá</small>
            </div>
        `;
      })
      .join("");

    let filteredReviews = reviews;

    if (currentReviewFilter !== "all") {
      filteredReviews = reviews.filter(
        (review) => review.rating === Number(currentReviewFilter),
      );
    }

    const totalFilteredReviews = filteredReviews.length;

    if (currentReviewFilter === "all") {
      commentTitle.textContent = `${totalFilteredReviews} Bình luận`;
    } else {
      commentTitle.textContent = `${totalFilteredReviews} Bình luận ${currentReviewFilter} sao`;
    }

    if (totalFilteredReviews === 0) {
      reviewList.innerHTML = `
            <p class="empty-review">
                Chưa có đánh giá ${currentReviewFilter} sao.
            </p>
        `;

      reviewPagination.innerHTML = "";
      return;
    }

    const totalPages = Math.ceil(totalFilteredReviews / reviewsPerPage);

    if (currentReviewPage > totalPages) {
      currentReviewPage = totalPages;
    }

    const startIndex = (currentReviewPage - 1) * reviewsPerPage;

    const endIndex = startIndex + reviewsPerPage;

    const currentPageReviews = filteredReviews.slice(startIndex, endIndex);

    reviewList.innerHTML = currentPageReviews
      .map(
        (review) => `
        <div class="review-item">
            <strong>👤 ${review.user}</strong>

            <div class="review-item-stars">
                ${renderStars(review.rating)}
            </div>

            <p>${review.comment}</p>
        </div>
    `,
      )
      .join("");

    renderReviewPagination(totalPages);
  }
  function renderReviewPagination(totalPages) {
    if (!reviewPagination) {
      return;
    }

    if (totalPages <= 1) {
      reviewPagination.innerHTML = `
            <button
                type="button"
                class="review-page-btn"
                disabled
            >
                ‹
            </button>

            <button
                type="button"
                class="review-page-btn active"
            >
                1
            </button>

            <button
                type="button"
                class="review-page-btn"
                disabled
            >
                ›
            </button>
        `;
      return;
    }

    let pageButtons = "";

    for (let page = 1; page <= totalPages; page++) {
      pageButtons += `
            <button
                type="button"
                class="review-page-btn ${page === currentReviewPage ? "active" : ""}"
                data-page="${page}"
            >
                ${page}
            </button>
        `;
    }

    reviewPagination.innerHTML = `
        <button
            type="button"
            class="review-page-btn review-prev"
            ${currentReviewPage === 1 ? "disabled" : ""}
        >
            ‹
        </button>

        ${pageButtons}

        <button
            type="button"
            class="review-page-btn review-next"
            ${currentReviewPage === totalPages ? "disabled" : ""}
        >
            ›
        </button>
    `;

    reviewPagination.querySelectorAll("[data-page]").forEach((button) => {
      button.addEventListener("click", () => {
        currentReviewPage = Number(button.dataset.page);

        renderReviews();
      });
    });

    reviewPagination
      .querySelector(".review-prev")
      ?.addEventListener("click", () => {
        if (currentReviewPage > 1) {
          currentReviewPage--;
          renderReviews();
        }
      });

    reviewPagination
      .querySelector(".review-next")
      ?.addEventListener("click", () => {
        if (currentReviewPage < totalPages) {
          currentReviewPage++;
          renderReviews();
        }
      });
  }
  function setupReviewFilters() {
    if (!reviewFilterButtons.length) {
      return;
    }

    reviewFilterButtons.forEach((button) => {
      button.addEventListener("click", () => {
        reviewFilterButtons.forEach((btn) => btn.classList.remove("active"));

        button.classList.add("active");

        currentReviewFilter = button.dataset.rating;

        currentReviewPage = 1;

        renderReviews();
      });
    });
  }
  // =========================
  // DETAIL ELEMENTS
  // =========================

  const detailImg = document.querySelector(".detail-img");
  const thumbList = document.querySelector(".thumb-list");
  const technicalImage = document.querySelector(".technical-image");
  const detailName = document.querySelector(".detail-name");
  const detailSold = document.querySelector(".detail-sold");
  const detailRating = document.querySelector(".detail-rating");
  const optionList = document.querySelector(".option-list");
  const colorOptions = document.querySelector(".color-options");
  const specTable = document.querySelector(".product-spec-table");
  const reviewAverage = document.querySelector(".review-average");
  const reviewCount = document.querySelector(".review-count");
  const reviewStars = document.querySelector(".review-stars");
  const reviewBars = document.querySelector(".review-bars");
  const commentTitle = document.querySelector(".comment-title");
  const reviewList = document.querySelector(".review-list");
  const reviewPagination = document.querySelector(".review-pagination");
  const reviewFilterButtons = document.querySelectorAll(
    ".review-filter button",
  );
  const highlightScreenSize = document.querySelector(".highlight-screen-size");
  const highlightChipset = document.querySelector(".highlight-chipset");
  let currentReviewPage = 1;
  let currentReviewFilter = "all";
  const reviewsPerPage = 3;

  function updateDetailUI() {
    const image = selectedColor ? selectedColor.image : product.image;

    if (detailImg) {
      detailImg.src = image;
      detailImg.alt = product.name;
    }
    if (technicalImage) {
      technicalImage.src = product.technicalImage || image;

      technicalImage.alt = `${product.name} technical image`;
    }
    const detailPrice = document.querySelector(".detail-price");

    if (detailPrice && selectedStorage) {
      detailPrice.textContent = selectedStorage.price;
    }

    const gallery = selectedColor?.gallery || product.gallery || [image];

    const thumbImages = document.querySelectorAll(".thumb-img");

    if (thumbList) {
      thumbList.innerHTML = `
        <button class="video-btn">
            Video
        </button>
    `;

      gallery.forEach((imgSrc, index) => {
        thumbList.innerHTML += `
            <img
                src="${imgSrc}"
                alt="${product.name}"
                class="thumb-img ${index === currentImageIndex ? "active" : ""}"
            >
        `;
      });

      const thumbImages = document.querySelectorAll(".thumb-img");

      thumbImages.forEach((img, index) => {
        img.onclick = () => {
          currentImageIndex = index;

          if (detailImg) {
            detailImg.src = gallery[index];
          }

          thumbImages.forEach((item) => item.classList.remove("active"));

          img.classList.add("active");
        };
      });
    }
  }

  if (detailName) {
    detailName.textContent = product.name;
  }

  if (detailSold) {
    detailSold.textContent = `Đã bán ${product.sold}`;
  }

  if (detailRating) {
    detailRating.innerHTML =
      product.rating > 0
        ? `⭐ ${product.rating} <span>Đánh giá sản phẩm</span>`
        : `☆ 0 <span>Chưa có đánh giá</span>`;
  }
  renderSpecs();
  /* DÁN CODE MODAL Ở ĐÂY */

  const specModal = document.querySelector("#spec-modal");

  const openSpecModalBtn = document.querySelector(".open-spec-modal");

  const closeSpecModalBtn = document.querySelector(".close-spec-modal");

  const specTabs = document.querySelector(".spec-tabs");

  const specModalBody = document.querySelector(".spec-modal-body");

  function renderFullSpecs() {
    if (!product.fullSpecifications) {
      return;
    }

    specTabs.innerHTML = getFullSpecifications()
      .map(
        (group, index) => `
            <button
                class="${index === 0 ? "active" : ""}"
                data-target="spec-group-${index}"
            >
                ${group.title}
            </button>
        `,
      )
      .join("");

    specModalBody.innerHTML = getFullSpecifications()
      .map(
        (group, index) => `
            <section
                class="spec-group"
                id="spec-group-${index}"
            >
                <h3>${group.title}</h3>

                <table class="spec-full-table">
                    ${group.items
                      .map(
                        (item) => `
                        <tr>
                            <td>${item.label}</td>
                            <td>${item.value}</td>
                        </tr>
                    `,
                      )
                      .join("")}
                </table>
            </section>
        `,
      )
      .join("");

    const tabButtons = specTabs.querySelectorAll("button");

    const specGroups = specModalBody.querySelectorAll(".spec-group");

    let isClickScrolling = false;
    let scrollTimer = null;
    let rafId = null;

    function setActiveTab(id) {
      tabButtons.forEach((button) => {
        button.classList.toggle("active", button.dataset.target === id);
      });
    }

    function scrollActiveTabIntoView(activeButton) {
      if (!activeButton) {
        return;
      }

      activeButton.scrollIntoView({
        behavior: "auto",
        inline: "center",
        block: "nearest",
      });
    }

    function updateActiveTabOnScroll() {
      if (isClickScrolling) {
        return;
      }

      if (rafId) {
        cancelAnimationFrame(rafId);
      }

      rafId = requestAnimationFrame(() => {
        let currentGroupId = specGroups[0]?.id;

        specGroups.forEach((group) => {
          const groupTop =
            group.getBoundingClientRect().top -
            specModalBody.getBoundingClientRect().top;

          if (groupTop <= 80) {
            currentGroupId = group.id;
          }
        });

        if (!currentGroupId) {
          return;
        }

        setActiveTab(currentGroupId);

        const activeButton = specTabs.querySelector(
          `button[data-target="${currentGroupId}"]`,
        );

        scrollActiveTabIntoView(activeButton);
      });
    }

    tabButtons.forEach((button) => {
      button.addEventListener("click", () => {
        const target = document.getElementById(button.dataset.target);

        if (!target) {
          return;
        }

        isClickScrolling = true;

        clearTimeout(scrollTimer);

        setActiveTab(button.dataset.target);
        scrollActiveTabIntoView(button);

        const targetTop =
          specModalBody.scrollTop +
          target.getBoundingClientRect().top -
          specModalBody.getBoundingClientRect().top -
          12;

        specModalBody.scrollTo({
          top: targetTop,
          behavior: "smooth",
        });

        scrollTimer = setTimeout(() => {
          isClickScrolling = false;
        }, 600);
      });
    });

    specModalBody.onscroll = updateActiveTabOnScroll;

    updateActiveTabOnScroll();
  }

  openSpecModalBtn?.addEventListener("click", () => {
    renderFullSpecs();

    specModal.classList.add("active");

    specModalBody.scrollTop = 0;

    const firstButton = specTabs.querySelector("button");

    specTabs
      .querySelectorAll("button")
      .forEach((btn) => btn.classList.remove("active"));

    firstButton?.classList.add("active");
  });

  closeSpecModalBtn?.addEventListener("click", () => {
    specModal.classList.remove("active");
  });
  // =========================
  // STORAGE OPTIONS
  // =========================

  if (optionList && product.storages) {
    optionList.innerHTML = product.storages
      .map(
        (item, index) => `
        <button
            class="${index === 0 ? "active" : ""}"
            data-index="${index}"
        >
            ${item.storage}
        </button>
    `,
      )
      .join("");

    optionList.querySelectorAll("button").forEach((button) => {
      button.addEventListener("click", () => {
        optionList.querySelectorAll("button").forEach((btn) => {
          btn.classList.remove("active");
        });

        button.classList.add("active");

        const index = Number(button.dataset.index);
        selectedStorage = product.storages[index];

        updateDetailUI();
        renderSpecs();
        renderHighlightSpecs();
      });
    });
  }

  // =========================
  // COLOR OPTIONS
  // =========================

  if (colorOptions && product.colors) {
    colorOptions.innerHTML = product.colors
      .map(
        (color, index) => `
        <button
            class="${index === 0 ? "active" : ""}"
            data-index="${index}"
        >
            <span style="background:${color.code}"></span>
            ${color.name}
        </button>
    `,
      )
      .join("");

    colorOptions.querySelectorAll("button").forEach((button) => {
      button.addEventListener("click", () => {
        colorOptions.querySelectorAll("button").forEach((btn) => {
          btn.classList.remove("active");
        });

        button.classList.add("active");

        const index = Number(button.dataset.index);
        selectedColor = product.colors[index];

        updateDetailUI();
      });
    });
  }

  updateDetailUI();
  renderSpecs();
  renderHighlightSpecs();
  renderReviews();
  setupReviewFilters();
  // =========================
  // GALLERY BUTTON
  // =========================

  const galleryPrevBtn = document.querySelector(".gallery-arrow.left");

  const galleryNextBtn = document.querySelector(".gallery-arrow.right");

  function getCurrentGallery() {
    const image = selectedColor ? selectedColor.image : product.image;

    return selectedColor?.gallery || product.gallery || [image];
  }

  function changeGalleryImage(step) {
    const gallery = getCurrentGallery();

    if (!gallery.length || !detailImg) {
      return;
    }

    currentImageIndex += step;

    if (currentImageIndex < 0) {
      currentImageIndex = gallery.length - 1;
    }

    if (currentImageIndex >= gallery.length) {
      currentImageIndex = 0;
    }

    detailImg.src = gallery[currentImageIndex];

    document
      .querySelectorAll(".thumb-img")
      .forEach((img) => img.classList.remove("active"));

    document
      .querySelectorAll(".thumb-img")
      [currentImageIndex]?.classList.add("active");
  }

  galleryPrevBtn?.addEventListener("click", () => {
    changeGalleryImage(-1);
  });

  galleryNextBtn?.addEventListener("click", () => {
    changeGalleryImage(1);
  });
  initQuantity();
  initCartButtons(product);
}

function initQuantity() {
  const minusBtn = document.querySelector(".qty-minus");
  const plusBtn = document.querySelector(".qty-plus");
  const qtyNumber = document.querySelector(".qty-number");

  if (!minusBtn || !plusBtn || !qtyNumber) return;

  let quantity = Number(qtyNumber.innerText) || 1;

  minusBtn.addEventListener("click", () => {
    if (quantity > 1) {
      quantity--;
      qtyNumber.innerText = quantity;
    }
  });

  plusBtn.addEventListener("click", () => {
    quantity++;
    qtyNumber.innerText = quantity;
  });
}

function getSelectedProductOptions(product) {
  const qtyNumber = document.querySelector(".qty-number");
  const quantity = Number(qtyNumber?.innerText || 1);

  const activeStorageBtn = document.querySelector(".option-list button.active");
  const activeColorBtn = document.querySelector(".color-options button.active");

  const storageIndex = Number(activeStorageBtn?.dataset.index || 0);
  const colorIndex = Number(activeColorBtn?.dataset.index || 0);

  const selectedStorage =
    product.storages?.[storageIndex] || product.storages?.[0] || {};

  const selectedColor =
    product.colors?.[colorIndex] || product.colors?.[0] || {};

  const storageName =
    selectedStorage.storage || activeStorageBtn?.innerText.trim() || "";
  const colorName =
    selectedColor.name || activeColorBtn?.innerText.trim() || "";

  const priceNumber =
    selectedStorage.priceNumber ||
    selectedStorage.price_number ||
    product.priceNumber ||
    product.price_number ||
    0;

  const price = selectedStorage.price || product.price || "";

  const image =
    document.querySelector(".detail-img")?.src ||
    selectedColor.image ||
    product.image ||
    "";

  const cartItemId = `${product.id}-${storageName}-${colorName}`;

  return {
    cartItemId: cartItemId,
    id: product.id,
    productId: product.id,
    name: product.name,
    image: image,
    price: price,
    priceNumber: priceNumber,
    storage: storageName,
    color: colorName,
    quantity: quantity,
    checked: false,
  };
}

function addItemToCart(cartItem, checked = false) {
  const cart = JSON.parse(localStorage.getItem("cart")) || [];

  const existingItem = cart.find(
    (item) => item.cartItemId === cartItem.cartItemId,
  );

  if (existingItem) {
    existingItem.quantity =
      Number(existingItem.quantity || 1) + Number(cartItem.quantity || 1);
    existingItem.checked = checked;
  } else {
    cart.push({
      ...cartItem,
      checked: checked,
    });
  }

  localStorage.setItem("cart", JSON.stringify(cart));
}

function initCartButtons(product) {
  const addCartBtn = document.querySelector(".add-cart-btn");
  const buyNowBtn = document.querySelector(".buy-now-btn");

  if (addCartBtn) {
    addCartBtn.addEventListener("click", () => {
      const cartItem = getSelectedProductOptions(product);

      addItemToCart(cartItem, false);

      alert("Đã thêm sản phẩm vào giỏ hàng!");
    });
  }

  if (buyNowBtn) {
    buyNowBtn.addEventListener("click", () => {
      const cartItem = getSelectedProductOptions(product);

      addItemToCart(cartItem, true);

      window.location.href = "/cart";
    });
  }
}

document.addEventListener("DOMContentLoaded", () => {
  renderPage();

  if (document.querySelector(".detail-page")) {
    renderDetailPage();
  }
});
