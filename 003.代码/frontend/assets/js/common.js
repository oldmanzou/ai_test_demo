/**
 * 瓷砖品牌商城 - 全局导航与公共函数
 * 版本: 1.0.0
 * 说明: 所有页面的导航跳转统一管理
 */

// ============================================================
// 页面路由表
// ============================================================
const ROUTES = {
  /** 认证相关 */
  LOGIN: '../../pages/auth/login.html',
  ROLE_SELECT: '../../pages/auth/role-select.html',
  PHONE_BIND: '../../pages/auth/phone-bind.html',

  /** 首页 */
  HOME: '../../pages/home/index.html',

  /** 产品相关 */
  SEARCH: '../../pages/product/search.html',
  SEARCH_RESULTS: '../../pages/product/search-results.html',
  CATEGORY: '../../pages/product/category.html',
  PRODUCT_DETAIL: '../../pages/product/detail.html',

  /** 购物车 */
  CART: '../../pages/cart/cart.html',

  /** 订单相关 */
  ORDER_CONFIRM: '../../pages/order/confirm.html',
  ORDER_LIST: '../../pages/order/list.html',
  ORDER_DETAIL: '../../pages/order/detail.html',
  PAYMENT_SUCCESS: '../../pages/order/payment-success.html',
  REFUND: '../../pages/order/refund.html',

  /** 用户相关 */
  PROFILE: '../../pages/user/profile.html',
  ADDRESS_LIST: '../../pages/user/address-list.html',
  ADDRESS_EDIT: '../../pages/user/address-edit.html',
  HELP: '../../pages/user/help.html',

  /** 案例 */
  CASE_DETAIL: '../../pages/case/detail.html',
};

// ============================================================
// 导航函数
// ============================================================

/**
 * 跳转到指定页面
 * @param {string} path - 目标页面路径
 * @param {boolean} replace - 是否替换历史记录
 */
function navigateTo(path, replace = false) {
  if (replace) {
    location.replace(path);
  } else {
    location.href = path;
  }
}

/**
 * 返回上一页
 */
function goBack() {
  window.history.back();
}

/**
 * 微信授权登录 -> 角色选择 -> 手机绑定 -> 首页
 */
function handleLogin() {
  // 模拟登录成功后跳转角色选择
  navigateTo(ROUTES.ROLE_SELECT);
}

function handleRoleConfirm() {
  // 选择角色后跳转手机绑定
  navigateTo(ROUTES.PHONE_BIND);
}

function handleSkipPhoneBind() {
  // 跳过手机绑定，直接进入首页
  navigateTo(ROUTES.HOME);
}

function handleBindPhone() {
  // 绑定手机号后进入首页
  navigateTo(ROUTES.HOME);
}

/**
 * 产品相关导航
 */
function goToProductDetail(productId) {
  navigateTo(ROUTES.PRODUCT_DETAIL + (productId ? '?id=' + productId : ''));
}

function goToSearch() {
  navigateTo(ROUTES.SEARCH);
}

function goToSearchResults() {
  navigateTo(ROUTES.SEARCH_RESULTS);
}

function goToCategory() {
  navigateTo(ROUTES.CATEGORY);
}

/**
 * 购物车导航
 */
function goToCart() {
  navigateTo(ROUTES.CART);
}

function addToCart() {
  // 加入购物车操作
  const toast = document.getElementById('toast');
  if (toast) {
    toast.classList.remove('hidden');
    setTimeout(() => toast.classList.add('hidden'), 2000);
  }
}

function goToCheckout() {
  navigateTo(ROUTES.ORDER_CONFIRM);
}

/**
 * 订单导航
 */
function goToOrderConfirm() {
  navigateTo(ROUTES.ORDER_CONFIRM);
}

function goToOrderList() {
  navigateTo(ROUTES.ORDER_LIST);
}

function goToOrderDetail() {
  navigateTo(ROUTES.ORDER_DETAIL);
}

function goToPaymentSuccess() {
  navigateTo(ROUTES.PAYMENT_SUCCESS);
}

function goToRefund() {
  navigateTo(ROUTES.REFUND);
}

/**
 * 用户中心导航
 */
function goToProfile() {
  navigateTo(ROUTES.PROFILE);
}

function goToAddressList() {
  navigateTo(ROUTES.ADDRESS_LIST);
}

function goToAddressEdit() {
  navigateTo(ROUTES.ADDRESS_EDIT);
}

function goToHelp() {
  navigateTo(ROUTES.HELP);
}

function goToCaseDetail() {
  navigateTo(ROUTES.CASE_DETAIL);
}

// ============================================================
// 底部导航栏初始化
// ============================================================

/**
 * 初始化底部导航栏的高亮状态
 * @param {string} activeTab - 当前激活的tab: 'home' | 'category' | 'cart' | 'profile'
 */
function initBottomNav(activeTab) {
  const navItems = document.querySelectorAll('.bottom-nav-item');
  if (!navItems.length) return;

  const tabRoutes = {
    home: ROUTES.HOME,
    category: ROUTES.CATEGORY,
    cart: ROUTES.CART,
    profile: ROUTES.PROFILE,
  };

  navItems.forEach((item) => {
    const tab = item.dataset.tab;
    if (tab === activeTab) {
      item.classList.add('text-primary', 'font-bold');
      item.classList.remove('text-text-gray');
    } else {
      item.classList.remove('text-primary', 'font-bold');
      item.classList.add('text-text-gray');
    }

    // 绑定点击跳转
    item.addEventListener('click', (e) => {
      e.preventDefault();
      if (tab && tabRoutes[tab]) {
        navigateTo(tabRoutes[tab]);
      }
    });
  });
}

// ============================================================
// Toast 提示
// ============================================================

function showToast(message, duration = 2000) {
  const existing = document.getElementById('global-toast');
  if (existing) {
    existing.remove();
  }
  const toast = document.createElement('div');
  toast.id = 'global-toast';
  toast.className =
    'fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-[999] bg-black/80 text-white px-6 py-3 rounded-lg text-body-md';
  toast.textContent = message;
  document.body.appendChild(toast);
  setTimeout(() => toast.remove(), duration);
}

// ============================================================
// 页面加载完成后自动执行
// ============================================================

document.addEventListener('DOMContentLoaded', () => {
  // 底部导航栏初始化 - 由各页面指定 activeTab
  const body = document.body;
  const activeTab = body.dataset.activeTab;
  if (activeTab) {
    initBottomNav(activeTab);
  }
});
