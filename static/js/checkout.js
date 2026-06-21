function formatMoney(number) {
  return Number(number || 0).toLocaleString("vi-VN") + "đ";
}
function parsePrice(value) {
  if (typeof value === "number") return value;

  return Number(String(value || "").replace(/[^\d]/g, ""));
}
const shippingFee = 14000;
const vouchers = [
  {
    code: "TECH5",
    name: "TECH 5",
    percent: 5,
    maxDiscount: 500000,
    minOrder: 0,
    active: true,
  },
  {
    code: "TECH10",
    name: "TECH 10",
    percent: 10,
    maxDiscount: 1000000,
    minOrder: 5000000,
    active: true,
  },
  {
    code: "TECH15",
    name: "TECH 15",
    percent: 15,
    maxDiscount: 2000000,
    minOrder: 20000000,
    active: false,
  },
];

let currentSubtotal = 0;
let selectedVoucher = null;

function updateCheckoutTotal() {
  const subtotalEl = document.getElementById("checkoutSubtotal");
  const totalEl = document.getElementById("checkoutTotal");
  const discountEl = document.getElementById("checkoutDiscount");
  const discountLine = document.querySelector(".discount-line");

  let discount = 0;

  if (selectedVoucher) {
    discount = Math.min(
      (currentSubtotal * selectedVoucher.percent) / 100,
      selectedVoucher.maxDiscount,
    );
  }

  subtotalEl.textContent = formatMoney(currentSubtotal);
  totalEl.textContent = formatMoney(currentSubtotal + shippingFee - discount);

  if (discountEl && discountLine) {
    discountLine.style.display = discount > 0 ? "flex" : "none";
    discountEl.textContent = "-" + formatMoney(discount);
  }
}
async function getCheckoutItems() {
  const checkoutItems = JSON.parse(localStorage.getItem("checkoutItems")) || [];

  try {
    const response = await fetch("/api/products");
    const products = await response.json();

    return checkoutItems.map((cartItem) => {
      const product = products.find(
        (p) => Number(p.id) === Number(cartItem.id),
      );

      if (!product) return cartItem;

      const storage =
        product.storages?.find((s) => s.storage === cartItem.storage) ||
        product.storages?.[0];

      const color =
        product.colors?.find((c) => c.name === cartItem.color) ||
        product.colors?.[0];

      return {
        ...cartItem,
        name: product.name,
        image: cartItem.image || color?.image || product.image,
        priceNumber:
          cartItem.priceNumber ||
          cartItem.price_number ||
          storage?.priceNumber ||
          storage?.price_number ||
          product.priceNumber ||
          product.price_number ||
          0,
        price: cartItem.price || storage?.price || product.price || "",
      };
    });
  } catch (error) {
    console.error("Lỗi đồng bộ sản phẩm checkout:", error);
    return checkoutItems;
  }
}

async function renderCheckoutItems() {
  const items = await getCheckoutItems();
  const container = document.querySelector(".checkout-items");
  if (!container) return;
  let subtotal = 0;

  if (!items.length) {
    container.innerHTML = "<p>Chưa có sản phẩm.</p>";
    currentSubtotal = 0;
    updateCheckoutTotal();
    return;
  }

  container.innerHTML = items
    .map((item) => {
      const quantity = Number(item.quantity || 1);

      const price = parsePrice(
        item.priceNumber || item.price_number || item.price,
      );

      subtotal += price * quantity;

      return `
        <div class="checkout-product">
          <img src="${item.image}" alt="${item.name}">
          <div>
            <h3>${item.name}</h3>
            <p>${item.color || ""}, ${item.storage || ""}</p>
          </div>
        </div>
      `;
    })
    .join("");

  currentSubtotal = subtotal;
  updateCheckoutTotal();
}

document.querySelectorAll(".receive-option").forEach((option) => {
  option.addEventListener("click", () => {
    document.querySelectorAll(".receive-option").forEach((item) => {
      item.classList.remove("active");
    });

    option.classList.add("active");

    const type = option.querySelector("input").value;

    document.getElementById("deliveryBox").style.display =
      type === "delivery" ? "block" : "none";

    document.getElementById("storeBox").style.display =
      type === "store" ? "block" : "none";
  });
});

document.querySelector(".place-order-btn").addEventListener("click", () => {
  const paymentValue = document.querySelector(
    "input[name='payment']:checked",
  )?.value;

  if (paymentValue === "card") {
    const cardNumber = cardNumberInput.value.trim();
    const cardExpiry = cardExpiryInput.value.trim();
    const cardCvv = cardCvvInput.value.trim();

    if (!cardNumber || !cardExpiry || !cardCvv) {
      alert("Vui lòng nhập đầy đủ thông tin thẻ.");
      return;
    }

    if (cardNumber.replace(/\D/g, "").length !== 16) {
      alert("Số thẻ phải gồm 16 số.");
      return;
    }

    if (cardCvv.length !== 3) {
      alert("CVV phải gồm 3 số.");
      return;
    }

    cardExpiryInput.dispatchEvent(new Event("blur"));

    if (cardExpiryInput.classList.contains("input-invalid")) {
      return;
    }
  }

  document.getElementById("otpOrderOverlay").style.display = "flex";
});

renderCheckoutItems();

// =====================================
const cardNumberInput = document.getElementById("cardNumber");
const cardExpiryInput = document.getElementById("cardExpiry");
const cardCvvInput = document.getElementById("cardCvv");
const cardInputs = document.querySelector(".card-inputs");
const paymentRadios = document.querySelectorAll("input[name='payment']");

if (cardNumberInput) {
  cardNumberInput.addEventListener("input", () => {
    let value = cardNumberInput.value.replace(/\D/g, "").slice(0, 16);
    cardNumberInput.value = value.replace(/(.{4})/g, "$1 ").trim();
  });
}

const cardExpiryError = document.getElementById("cardExpiryError");

function showExpiryError(message) {
  if (!cardExpiryError) return;
  cardExpiryError.textContent = message;
  cardExpiryError.style.display = "block";
  cardExpiryInput.classList.add("input-invalid");
}

function hideExpiryError() {
  if (!cardExpiryError) return;
  cardExpiryError.textContent = "";
  cardExpiryError.style.display = "none";
  cardExpiryInput.classList.remove("input-invalid");
}

if (cardExpiryInput) {
  cardExpiryInput.addEventListener("input", () => {
    hideExpiryError();

    let value = cardExpiryInput.value.replace(/\D/g, "").slice(0, 4);

    let month = value.slice(0, 2);
    let year = value.slice(2, 4);

    if (month.length === 2) {
      let monthNumber = Number(month);

      if (monthNumber < 1) month = "01";
      if (monthNumber > 12) month = "12";
    }

    cardExpiryInput.value = value.length >= 3 ? month + "/" + year : month;
  });

  cardExpiryInput.addEventListener("blur", () => {
    const value = cardExpiryInput.value.trim();

    if (!/^\d{2}\/\d{2}$/.test(value)) {
      showExpiryError("Vui lòng nhập đúng định dạng MM/YY.");
      return;
    }

    const [month, year] = value.split("/").map(Number);

    const now = new Date();
    const currentMonth = now.getMonth() + 1;
    const currentYear = now.getFullYear() % 100;

    if (year < currentYear || (year === currentYear && month <= currentMonth)) {
      showExpiryError("Thời gian không hợp lệ.");
      return;
    }

    hideExpiryError();
  });

  if (cardCvvInput) {
    cardCvvInput.addEventListener("input", () => {
      cardCvvInput.value = cardCvvInput.value.replace(/\D/g, "").slice(0, 3);
    });
  }
  const toggleCvvBtn = document.getElementById("toggleCvvBtn");

  if (toggleCvvBtn && cardCvvInput) {
    toggleCvvBtn.addEventListener("click", () => {
      if (cardCvvInput.type === "password") {
        cardCvvInput.type = "text";
        toggleCvvBtn.src = "/static/img/view-eye.png";
      } else {
        cardCvvInput.type = "password";
        toggleCvvBtn.src = "/static/img/hide-eye.png";
      }
    });
  }
  function toggleCardInputs() {
    if (!cardInputs) return;

    const checkedPayment = document.querySelector(
      "input[name='payment']:checked",
    );

    if (!checkedPayment) return;

    if (checkedPayment.value === "card") {
      cardInputs.style.display = "block";
    } else {
      cardInputs.style.display = "none";
    }
  }

  paymentRadios.forEach((radio) => {
    radio.addEventListener("change", toggleCardInputs);
  });

  toggleCardInputs();

  function applyVoucherByCode(code) {
    const voucher = vouchers.find((item) => item.code === code);

    if (!voucher) {
      alert("Mã giảm giá không tồn tại.");
      selectedVoucher = null;
      updateCheckoutTotal();
      return;
    }

    if (!voucher.active) {
      alert("Mã giảm giá chưa khả dụng.");
      selectedVoucher = null;
      updateCheckoutTotal();
      return;
    }

    if (currentSubtotal < voucher.minOrder) {
      alert(
        `Đơn hàng cần tối thiểu ${formatMoney(voucher.minOrder)} để dùng mã này.`,
      );
      selectedVoucher = null;
      updateCheckoutTotal();
      return;
    }

    selectedVoucher = voucher;
    updateCheckoutTotal();

    document.querySelectorAll(".voucher").forEach((item) => {
      item.classList.remove("active");
    });

    const matchedVoucher = [...document.querySelectorAll(".voucher")].find(
      (item) => item.dataset.code === code,
    );

    if (matchedVoucher) {
      matchedVoucher.classList.add("active");
    }
  }

  document
    .querySelector(".coupon-input button")
    ?.addEventListener("click", () => {
      const input = document.querySelector(".coupon-input input");
      const code = input.value.trim().toUpperCase();

      applyVoucherByCode(code);
    });

  document.querySelectorAll(".voucher").forEach((voucherEl) => {
    voucherEl.addEventListener("click", () => {
      const code = voucherEl.dataset.code;

      if (!code) return;

      document.querySelector(".coupon-input input").value = code;
      applyVoucherByCode(code);
    });
  });
  document.querySelectorAll(".store-option").forEach((option) => {
    option.addEventListener("click", () => {
      document.querySelectorAll(".store-option").forEach((item) => {
        item.classList.remove("active");
      });

      option.classList.add("active");
      option.querySelector("input").checked = true;
    });
  });
  document.querySelectorAll(".payment-option").forEach((option) => {
    option.addEventListener("click", () => {
      document.querySelectorAll(".payment-option").forEach((item) => {
        item.classList.remove("active");
      });

      option.classList.add("active");
      option.querySelector("input").checked = true;

      toggleCardInputs();
    });
  });
  const addressModalOverlay = document.getElementById("addressModalOverlay");
  const openAddressModalBtn = document.getElementById("openAddressModalBtn");
  const closeAddressModalBtn = document.getElementById("closeAddressModalBtn");
  const backAddressBtn = document.getElementById("backAddressBtn");
  const saveAddressBtn = document.getElementById("saveAddressBtn");
  const addressDisplay = document.getElementById("addressDisplay");

  function openAddressModal() {
    addressModalOverlay.style.display = "flex";
  }

  function closeAddressModal() {
    addressModalOverlay.style.display = "none";
  }

  openAddressModalBtn?.addEventListener("click", (e) => {
    e.preventDefault();
    openAddressModal();
  });

  closeAddressModalBtn?.addEventListener("click", closeAddressModal);
  backAddressBtn?.addEventListener("click", closeAddressModal);

  addressModalOverlay?.addEventListener("click", (e) => {
    if (e.target === addressModalOverlay) {
      closeAddressModal();
    }
  });

  saveAddressBtn?.addEventListener("click", () => {
    const name = document.getElementById("addressName").value.trim();
    const phone = document.getElementById("addressPhone").value.trim();
    const detail = document.getElementById("addressDetail").value.trim();
    const city = document.getElementById("addressCity").value;
    const district = document.getElementById("addressDistrict").value;
    const ward = document.getElementById("addressWard").value;

    if (!name || !phone || !detail || !city || !district || !ward) {
      alert("Vui lòng nhập đầy đủ địa chỉ.");
      return;
    }

    addressDisplay.innerHTML = `
    <p>
      <strong>${name}</strong> ${phone}
      <span>${detail}, ${ward}, ${district}, ${city}</span>
    </p>
    <button type="button" id="changeAddressBtn">Thay Đổi</button>
  `;

    document
      .getElementById("changeAddressBtn")
      .addEventListener("click", openAddressModal);

    closeAddressModal();
  });
  const otpOrderOverlay = document.getElementById("otpOrderOverlay");
  const orderSuccessOverlay = document.getElementById("orderSuccessOverlay");
  const orderOtpInputs = document.querySelectorAll(".order-otp-inputs input");
  const orderOtpError = document.getElementById("orderOtpError");

  document
    .getElementById("cancelOrderOtpBtn")
    ?.addEventListener("click", () => {
      otpOrderOverlay.style.display = "none";
    });

  orderOtpInputs.forEach((input, index) => {
    input.addEventListener("input", () => {
      input.value = input.value.replace(/\D/g, "");

      if (input.value && index < orderOtpInputs.length - 1) {
        orderOtpInputs[index + 1].focus();
      }
    });
  });

  document
    .getElementById("confirmOrderOtpBtn")
    ?.addEventListener("click", async () => {
      let otp = "";

      orderOtpInputs.forEach((input) => {
        otp += input.value;
      });

      if (otp !== "279279") {
        alert("Mã OTP không đúng.");
        return;
      }

      const items = await getCheckoutItems();

      if (!items.length) {
        alert("Không có sản phẩm để đặt hàng.");
        return;
      }

      const normalizedItems = items.map((item) => {
        const id = item.id || item.productId || item.product_id;

        return {
          ...item,
          id: id,
          productId: id,
          name: item.name || item.product_name || "Sản phẩm",
          color: item.color || "",
          storage: item.storage || "",
          quantity: Number(item.quantity || 1),
          priceNumber: parsePrice(
            item.priceNumber || item.price_number || item.price || 0,
          ),
          image: item.image || "",
        };
      });

      const discountText = document
        .getElementById("checkoutDiscount")
        .textContent.replace(/[^\d]/g, "");

      const orderData = {
        items: normalizedItems,
        receiveType: document.querySelector("input[name='receiveType']:checked")
          ?.value,
        paymentMethod: document.querySelector("input[name='payment']:checked")
          ?.value,

        customerName: document.getElementById("addressName")?.value || "",
        customerPhone: document.getElementById("addressPhone")?.value || "",
        addressDetail: document.getElementById("addressDetail")?.value || "",
        city: document.getElementById("addressCity")?.value || "",
        district: document.getElementById("addressDistrict")?.value || "",
        ward: document.getElementById("addressWard")?.value || "",

        subtotal: currentSubtotal,
        shippingFee: shippingFee,
        discount: Number(discountText || 0),
        total: parsePrice(document.getElementById("checkoutTotal").textContent),
      };

      const response = await fetch("/api/orders", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(orderData),
      });

      const result = await response.json();

      if (!result.success) {
        alert(result.message || "Không thể lưu đơn hàng.");
        return;
      }

      otpOrderOverlay.style.display = "none";

      document.getElementById("successOrderCode").textContent =
        result.orderCode;
      document.getElementById("successOrderTotal").textContent =
        document.getElementById("checkoutTotal").textContent;

      orderSuccessOverlay.style.display = "flex";
      // Xóa sản phẩm đã thanh toán khỏi checkout tạm
      localStorage.removeItem("checkoutItems");

      // Xóa đúng sản phẩm đã thanh toán khỏi giỏ hàng
      function makeCartKey(item) {
        const id = String(item.id || item.productId || item.product_id || "");
        const color = String(item.color || "").trim();
        const storage = String(item.storage || "").trim();

        return `${id}|${color}|${storage}`;
      }

      const cart = JSON.parse(localStorage.getItem("cart")) || [];
      const paidItemKeys = new Set(normalizedItems.map(makeCartKey));

      const newCart = cart.filter((cartItem) => {
        return !paidItemKeys.has(makeCartKey(cartItem));
      });

      localStorage.setItem("cart", JSON.stringify(newCart));

      // Success modal button handlers
      document.getElementById("viewOrderBtn")?.addEventListener("click", () => {
        window.location.href = "/orders";
      });

      document.getElementById("homeBtn")?.addEventListener("click", () => {
        window.location.href = "/";
      });
    });
}
