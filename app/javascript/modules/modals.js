// Modals Module
class Modals {
  constructor() {
    this.initializeModals();
    this.setupKeyboardHandling();
  }

  initializeModals() {
    // Initialize modal triggers
    const modalTriggers = document.querySelectorAll('[data-modal-target]');
    modalTriggers.forEach(trigger => {
      trigger.addEventListener('click', (e) => {
        e.preventDefault();
        const modalId = trigger.dataset.modalTarget;
        this.openModal(modalId);
      });
    });

    // Initialize modal close buttons
    const closeButtons = document.querySelectorAll('[data-modal-close]');
    closeButtons.forEach(button => {
      button.addEventListener('click', () => {
        this.closeModal(button.closest('.modal-overlay'));
      });
    });

    // Initialize overlay clicks
    const overlays = document.querySelectorAll('.modal-overlay');
    overlays.forEach(overlay => {
      overlay.addEventListener('click', (e) => {
        if (e.target === overlay) {
          this.closeModal(overlay);
        }
      });
    });
  }

  setupKeyboardHandling() {
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        const openModal = document.querySelector('.modal-overlay:not(.hidden)');
        if (openModal) {
          this.closeModal(openModal);
        }
      }
    });
  }

  openModal(modalId) {
    const modal = document.getElementById(modalId);
    if (!modal) return;

    // Store the currently focused element
    this.previouslyFocused = document.activeElement;

    // Show modal
    modal.classList.remove('hidden');
    document.body.classList.add('modal-open');

    // Focus management
    const focusableElements = modal.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    );
    
    if (focusableElements.length > 0) {
      focusableElements[0].focus();
    }

    // Trap focus within modal
    this.trapFocus(modal, focusableElements);

    // Trigger custom event
    modal.dispatchEvent(new CustomEvent('modal:opened', { detail: { modalId } }));
  }

  closeModal(modal) {
    if (!modal) return;

    modal.classList.add('hidden');
    document.body.classList.remove('modal-open');

    // Restore focus
    if (this.previouslyFocused) {
      this.previouslyFocused.focus();
    }

    // Remove focus trap
    this.removeFocusTrap(modal);

    // Trigger custom event
    const modalId = modal.id;
    modal.dispatchEvent(new CustomEvent('modal:closed', { detail: { modalId } }));
  }

  trapFocus(modal, focusableElements) {
    if (focusableElements.length === 0) return;

    const firstElement = focusableElements[0];
    const lastElement = focusableElements[focusableElements.length - 1];

    const handleTabKey = (e) => {
      if (e.key !== 'Tab') return;

      if (e.shiftKey) {
        if (document.activeElement === firstElement) {
          e.preventDefault();
          lastElement.focus();
        }
      } else {
        if (document.activeElement === lastElement) {
          e.preventDefault();
          firstElement.focus();
        }
      }
    };

    modal.addEventListener('keydown', handleTabKey);
    modal._focusTrapHandler = handleTabKey;
  }

  removeFocusTrap(modal) {
    if (modal._focusTrapHandler) {
      modal.removeEventListener('keydown', modal._focusTrapHandler);
      delete modal._focusTrapHandler;
    }
  }

  // Public API methods
  static open(modalId) {
    const modals = new Modals();
    modals.openModal(modalId);
  }

  static close(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
      const modals = new Modals();
      modals.closeModal(modal);
    }
  }

  static confirm(options = {}) {
    const {
      title = 'Confirm Action',
      message = 'Are you sure you want to continue?',
      confirmText = 'Confirm',
      cancelText = 'Cancel',
      confirmClass = 'btn-danger',
      onConfirm = () => {},
      onCancel = () => {}
    } = options;

    return new Promise((resolve) => {
      // Create modal HTML
      const modalHtml = `
        <div id="confirm-modal" class="modal-overlay">
          <div class="modal max-w-md">
            <div class="modal-header">
              <h3 class="modal-title">${title}</h3>
              <button type="button" class="text-gray-400 hover:text-gray-600" data-modal-close>
                <div class="icon icon-x"></div>
              </button>
            </div>
            <div class="modal-body">
              <p class="text-gray-600">${message}</p>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" data-action="cancel">
                ${cancelText}
              </button>
              <button type="button" class="btn ${confirmClass}" data-action="confirm">
                ${confirmText}
              </button>
            </div>
          </div>
        </div>
      `;

      // Add modal to DOM
      document.body.insertAdjacentHTML('beforeend', modalHtml);
      const modal = document.getElementById('confirm-modal');

      // Handle button clicks
      modal.addEventListener('click', (e) => {
        const action = e.target.dataset.action;
        
        if (action === 'confirm') {
          onConfirm();
          resolve(true);
        } else if (action === 'cancel' || e.target.closest('[data-modal-close]')) {
          onCancel();
          resolve(false);
        }

        // Remove modal
        modal.remove();
        document.body.classList.remove('modal-open');
      });

      // Open modal
      const modals = new Modals();
      modals.openModal('confirm-modal');
    });
  }

  static alert(options = {}) {
    const {
      title = 'Alert',
      message = 'Something happened.',
      buttonText = 'OK',
      buttonClass = 'btn-primary',
      onClose = () => {}
    } = options;

    return new Promise((resolve) => {
      // Create modal HTML
      const modalHtml = `
        <div id="alert-modal" class="modal-overlay">
          <div class="modal max-w-md">
            <div class="modal-header">
              <h3 class="modal-title">${title}</h3>
              <button type="button" class="text-gray-400 hover:text-gray-600" data-modal-close>
                <div class="icon icon-x"></div>
              </button>
            </div>
            <div class="modal-body">
              <p class="text-gray-600">${message}</p>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn ${buttonClass}" data-action="ok">
                ${buttonText}
              </button>
            </div>
          </div>
        </div>
      `;

      // Add modal to DOM
      document.body.insertAdjacentHTML('beforeend', modalHtml);
      const modal = document.getElementById('alert-modal');

      // Handle button clicks
      modal.addEventListener('click', (e) => {
        if (e.target.dataset.action === 'ok' || e.target.closest('[data-modal-close]')) {
          onClose();
          resolve();
          
          // Remove modal
          modal.remove();
          document.body.classList.remove('modal-open');
        }
      });

      // Open modal
      const modals = new Modals();
      modals.openModal('alert-modal');
    });
  }
}

// Add CSS for modal-open body
const style = document.createElement('style');
style.textContent = `
  body.modal-open {
    overflow: hidden;
  }
  
  .modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
  }
  
  .modal-overlay.hidden {
    display: none;
  }
`;
document.head.appendChild(style);

// Initialize modals
document.addEventListener('DOMContentLoaded', () => {
  new Modals();
});

// Re-initialize after Turbo navigations
document.addEventListener('turbo:load', () => {
  new Modals();
});

// Export for manual use
window.Modals = Modals;

export default Modals;
