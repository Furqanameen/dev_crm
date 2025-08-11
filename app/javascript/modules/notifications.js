// Notifications Module
class Notifications {
  constructor() {
    this.container = this.createContainer();
    this.initializeExistingNotifications();
  }

  createContainer() {
    let container = document.querySelector('.notifications-container');
    
    if (!container) {
      container = document.createElement('div');
      container.className = 'notifications-container';
      container.setAttribute('aria-live', 'polite');
      container.setAttribute('aria-label', 'Notifications');
      document.body.appendChild(container);
    }
    
    return container;
  }

  initializeExistingNotifications() {
    // Handle existing Rails flash messages
    const flashMessages = document.querySelectorAll('.alert, .flash-message');
    flashMessages.forEach(message => {
      this.enhanceFlashMessage(message);
    });
  }

  enhanceFlashMessage(message) {
    // Add close button if not present
    if (!message.querySelector('.notification-close')) {
      const closeButton = document.createElement('button');
      closeButton.className = 'notification-close ml-auto';
      closeButton.innerHTML = '<div class="icon icon-x"></div>';
      closeButton.addEventListener('click', () => {
        this.dismissNotification(message);
      });
      
      message.appendChild(closeButton);
    }

    // Auto-dismiss after 5 seconds for non-error messages
    if (!message.classList.contains('alert-danger') && !message.classList.contains('error')) {
      setTimeout(() => {
        this.dismissNotification(message);
      }, 5000);
    }
  }

  show(message, type = 'info', options = {}) {
    const {
      duration = type === 'error' ? 0 : 5000, // Errors don't auto-dismiss
      closable = true,
      icon = true,
      position = 'top-right'
    } = options;

    const notification = this.createNotification(message, type, { closable, icon });
    
    // Position the container
    this.positionContainer(position);
    
    // Add to container
    this.container.appendChild(notification);
    
    // Animate in
    requestAnimationFrame(() => {
      notification.classList.add('notification-show');
    });

    // Auto-dismiss
    if (duration > 0) {
      setTimeout(() => {
        this.dismissNotification(notification);
      }, duration);
    }

    return notification;
  }

  createNotification(message, type, options) {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    
    const iconHtml = options.icon ? this.getIcon(type) : '';
    const closeHtml = options.closable ? '<button class="notification-close"><div class="icon icon-x"></div></button>' : '';
    
    notification.innerHTML = `
      <div class="notification-content">
        ${iconHtml}
        <div class="notification-message">${message}</div>
        ${closeHtml}
      </div>
    `;

    // Add close handler
    if (options.closable) {
      const closeButton = notification.querySelector('.notification-close');
      closeButton.addEventListener('click', () => {
        this.dismissNotification(notification);
      });
    }

    return notification;
  }

  getIcon(type) {
    const icons = {
      success: 'check',
      error: 'x',
      warning: 'warning',
      info: 'info'
    };
    
    const iconName = icons[type] || 'info';
    return `<div class="notification-icon icon icon-${iconName}"></div>`;
  }

  positionContainer(position) {
    const positions = {
      'top-right': 'top: 1rem; right: 1rem;',
      'top-left': 'top: 1rem; left: 1rem;',
      'bottom-right': 'bottom: 1rem; right: 1rem;',
      'bottom-left': 'bottom: 1rem; left: 1rem;',
      'top-center': 'top: 1rem; left: 50%; transform: translateX(-50%);',
      'bottom-center': 'bottom: 1rem; left: 50%; transform: translateX(-50%);'
    };

    this.container.style.cssText = `
      position: fixed;
      z-index: 9999;
      pointer-events: none;
      ${positions[position] || positions['top-right']}
    `;
  }

  dismissNotification(notification) {
    notification.classList.add('notification-hide');
    
    // Remove after animation
    setTimeout(() => {
      if (notification.parentNode) {
        notification.parentNode.removeChild(notification);
      }
    }, 300);
  }

  // Convenience methods
  success(message, options = {}) {
    return this.show(message, 'success', options);
  }

  error(message, options = {}) {
    return this.show(message, 'error', options);
  }

  warning(message, options = {}) {
    return this.show(message, 'warning', options);
  }

  info(message, options = {}) {
    return this.show(message, 'info', options);
  }

  // Progress notification
  progress(message, options = {}) {
    const notification = this.createProgressNotification(message, options);
    this.container.appendChild(notification);
    
    requestAnimationFrame(() => {
      notification.classList.add('notification-show');
    });

    return {
      notification,
      updateProgress: (percent) => {
        const progressBar = notification.querySelector('.progress-bar-fill');
        if (progressBar) {
          progressBar.style.width = `${percent}%`;
        }
      },
      complete: (successMessage) => {
        if (successMessage) {
          const messageEl = notification.querySelector('.notification-message');
          messageEl.textContent = successMessage;
        }
        
        notification.classList.remove('notification-progress');
        notification.classList.add('notification-success');
        
        setTimeout(() => {
          this.dismissNotification(notification);
        }, 2000);
      },
      dismiss: () => {
        this.dismissNotification(notification);
      }
    };
  }

  createProgressNotification(message, options = {}) {
    const notification = document.createElement('div');
    notification.className = 'notification notification-progress';
    
    notification.innerHTML = `
      <div class="notification-content">
        <div class="notification-icon">
          <div class="spinner"></div>
        </div>
        <div class="notification-body">
          <div class="notification-message">${message}</div>
          <div class="progress mt-2">
            <div class="progress-bar-fill" style="width: 0%"></div>
          </div>
        </div>
        ${options.closable !== false ? '<button class="notification-close"><div class="icon icon-x"></div></button>' : ''}
      </div>
    `;

    if (options.closable !== false) {
      const closeButton = notification.querySelector('.notification-close');
      closeButton.addEventListener('click', () => {
        this.dismissNotification(notification);
      });
    }

    return notification;
  }

  // Clear all notifications
  clearAll() {
    const notifications = this.container.querySelectorAll('.notification');
    notifications.forEach(notification => {
      this.dismissNotification(notification);
    });
  }
}

// Add CSS for notifications
const style = document.createElement('style');
style.textContent = `
  .notifications-container {
    width: 320px;
    max-width: calc(100vw - 2rem);
  }
  
  .notification {
    background: white;
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-lg);
    border: 1px solid var(--gray-200);
    margin-bottom: 0.5rem;
    pointer-events: auto;
    transform: translateX(100%);
    opacity: 0;
    transition: all 0.3s ease-in-out;
  }
  
  .notification.notification-show {
    transform: translateX(0);
    opacity: 1;
  }
  
  .notification.notification-hide {
    transform: translateX(100%);
    opacity: 0;
  }
  
  .notification-content {
    display: flex;
    align-items: flex-start;
    padding: 1rem;
  }
  
  .notification-icon {
    flex-shrink: 0;
    width: 1.25rem;
    height: 1.25rem;
    margin-right: 0.75rem;
    margin-top: 0.125rem;
  }
  
  .notification-message {
    flex: 1;
    font-size: 0.875rem;
    line-height: 1.5;
    color: var(--gray-900);
  }
  
  .notification-close {
    flex-shrink: 0;
    margin-left: 0.75rem;
    padding: 0.25rem;
    background: none;
    border: none;
    color: var(--gray-400);
    cursor: pointer;
    border-radius: var(--radius-sm);
    transition: color 0.15s ease-in-out;
  }
  
  .notification-close:hover {
    color: var(--gray-600);
  }
  
  .notification-success {
    border-left: 4px solid #10b981;
  }
  
  .notification-success .notification-icon {
    color: #10b981;
  }
  
  .notification-error {
    border-left: 4px solid #ef4444;
  }
  
  .notification-error .notification-icon {
    color: #ef4444;
  }
  
  .notification-warning {
    border-left: 4px solid #f59e0b;
  }
  
  .notification-warning .notification-icon {
    color: #f59e0b;
  }
  
  .notification-info {
    border-left: 4px solid var(--primary-500);
  }
  
  .notification-info .notification-icon {
    color: var(--primary-500);
  }
  
  .notification-progress {
    border-left: 4px solid var(--primary-500);
  }
  
  .notification-body {
    flex: 1;
  }
`;
document.head.appendChild(style);

// Initialize notifications
let notificationsInstance;

document.addEventListener('DOMContentLoaded', () => {
  notificationsInstance = new Notifications();
  window.Notifications = notificationsInstance;
});

// Re-initialize after Turbo navigations
document.addEventListener('turbo:load', () => {
  if (!notificationsInstance) {
    notificationsInstance = new Notifications();
    window.Notifications = notificationsInstance;
  } else {
    notificationsInstance.initializeExistingNotifications();
  }
});

export default Notifications;
