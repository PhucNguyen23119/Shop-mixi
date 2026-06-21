function formatMoney(number) {
  return Number(number || 0).toLocaleString("vi-VN") + "đ";
}

function getCart() {
  return JSON.parse(localStorage.getItem("cart")) || [];
}

function saveCart(cart) {
  localStorage.setItem("cart", JSON.stringify(cart));
}

function renderCart() {
  const cartList = document.querySelector(".cart-list");
  const cartContainer = document.querySelector(".cart-container");
  const cartEmptyPage = document.querySelector(".cart-empty-page");

  const cart = getCart();

  if (!cartList || !cartContainer || !cartEmptyPage) return;

  if (cart.length === 0) {
    cartContainer.style.display = "none";
    cartEmptyPage.style.display = "flex";

    window.scrollTo({
      top: 0,
      behavior: "auto",
    });

    return;
  }

  cartContainer.style.display = "block";
  cartEmptyPage.style.display = "none";

  cartList.innerHTML = cart
    .map((item, index) => {
      const quantity = Number(item.quantity || 1);
      const priceNumber = Number(item.priceNumber || 0);
      const itemTotal = priceNumber * quantity;

      return `
        <div class="cart-item" data-index="${index}">
          <div class="cart-check">
            <input
              type="checkbox"
              class="cart-item-check"
              data-index="${index}"
              ${item.checked ? "checked" : ""}
            >
          </div>

          <div class="cart-product">
            <img src="${item.image}" alt="${item.name}">

            <div class="cart-product-info">
              <h3>${item.name}</h3>

              <div class="cart-tags">
                ${item.storage ? `<span>${item.storage}</span>` : ""}
                ${item.color ? `<span>${item.color}</span>` : ""}
              </div>
            </div>
          </div>

          <div class="cart-quantity">
            <div class="cart-quantity-box">
              <button type="button" class="cart-minus" data-index="${index}">-</button>
              <span>${quantity}</span>
              <button type="button" class="cart-plus" data-index="${index}">+</button>
            </div>
          </div>

          <div class="cart-price">
            ${formatMoney(itemTotal)}
          </div>

          <div class="cart-action">
            <button type="button" class="delete-cart-btn" data-index="${index}">
              🗑
            </button>
          </div>
        </div>
      `;
    })
    .join("");

  bindCartEvents();
  updateTotal();
}

function bindCartEvents() {
  document.querySelectorAll(".cart-plus").forEach((button) => {
    button.addEventListener("click", () => {
      const index = Number(button.dataset.index);
      const cart = getCart();

      cart[index].quantity = Number(cart[index].quantity || 1) + 1;

      saveCart(cart);
      renderCart();
    });
  });

  document.querySelectorAll(".cart-minus").forEach((button) => {
    button.addEventListener("click", () => {
      const index = Number(button.dataset.index);
      const cart = getCart();

      if (Number(cart[index].quantity || 1) > 1) {
        cart[index].quantity = Number(cart[index].quantity || 1) - 1;
      }

      saveCart(cart);
      renderCart();
    });
  });

  document.querySelectorAll(".delete-cart-btn").forEach((button) => {
    button.addEventListener("click", () => {
      const index = Number(button.dataset.index);
      const cart = getCart();

      cart.splice(index, 1);

      saveCart(cart);
      renderCart();
    });
  });

  document.querySelectorAll(".cart-item-check").forEach((checkbox) => {
    checkbox.addEventListener("change", () => {
      const index = Number(checkbox.dataset.index);
      const cart = getCart();

      cart[index].checked = checkbox.checked;

      saveCart(cart);
      updateTotal();
      syncSelectAll();
    });
  });
}

function syncSelectAll() {
  const cart = getCart();

  const selectAllTop = document.getElementById("select-all-top");
  const selectAllBottom = document.getElementById("select-all-bottom");

  const isAllChecked =
    cart.length > 0 && cart.every((item) => item.checked === true);

  if (selectAllTop) {
    selectAllTop.checked = isAllChecked;
  }

  if (selectAllBottom) {
    selectAllBottom.checked = isAllChecked;
  }
}

function updateTotal() {
  const cart = getCart();

  const selectedItems = cart.filter((item) => item.checked);

  const total = selectedItems.reduce((sum, item) => {
    return sum + Number(item.priceNumber || 0) * Number(item.quantity || 1);
  }, 0);

  const totalElement = document.querySelector(".cart-total");
  const selectedCount = document.querySelector(".selected-count");

  if (totalElement) {
    totalElement.textContent = formatMoney(total);
  }

  if (selectedCount) {
    selectedCount.textContent = `(${selectedItems.length} sản phẩm):`;
  }

  syncSelectAll();
}

function initSelectAll() {
  const selectAllTop = document.getElementById("select-all-top");
  const selectAllBottom = document.getElementById("select-all-bottom");

  function handleSelectAll(checked) {
    const cart = getCart();

    const newCart = cart.map((item) => ({
      ...item,
      checked: checked,
    }));

    saveCart(newCart);
    renderCart();
  }

  selectAllTop?.addEventListener("change", () => {
    handleSelectAll(selectAllTop.checked);
  });

  selectAllBottom?.addEventListener("change", () => {
    handleSelectAll(selectAllBottom.checked);
  });
}

function initDeleteSelected() {
  const deleteSelectedBtn = document.querySelector(".delete-selected-btn");

  deleteSelectedBtn?.addEventListener("click", () => {
    const cart = getCart();

    const newCart = cart.filter((item) => !item.checked);

    saveCart(newCart);
    renderCart();
  });
}

function initCheckout() {
  const checkoutBtn = document.querySelector(".checkout-btn");

  checkoutBtn?.addEventListener("click", () => {
    const cart = getCart();

    const selectedItems = cart.filter((item) => item.checked);

    if (selectedItems.length === 0) {
      alert("Vui lòng chọn sản phẩm cần mua!");
      return;
    }

    localStorage.setItem("checkoutItems", JSON.stringify(selectedItems));
    window.location.href = "/checkout";
  });
}

document.addEventListener("DOMContentLoaded", () => {
  renderCart();
  initSelectAll();
  initDeleteSelected();
  initCheckout();
});
