// Form Validation Module
class FormValidation {
  constructor() {
    this.initializeForms();
  }

  initializeForms() {
    const forms = document.querySelectorAll('form[data-validate]');
    
    forms.forEach(form => {
      this.setupFormValidation(form);
    });
  }

  setupFormValidation(form) {
    const inputs = form.querySelectorAll('input, select, textarea');
    
    inputs.forEach(input => {
      // Real-time validation on blur
      input.addEventListener('blur', () => {
        this.validateField(input);
      });
      
      // Clear errors on input
      input.addEventListener('input', () => {
        this.clearFieldError(input);
      });
    });
    
    // Form submission validation
    form.addEventListener('submit', (e) => {
      if (!this.validateForm(form)) {
        e.preventDefault();
        e.stopPropagation();
      }
    });
  }

  validateForm(form) {
    const inputs = form.querySelectorAll('input, select, textarea');
    let isValid = true;
    
    inputs.forEach(input => {
      if (!this.validateField(input)) {
        isValid = false;
      }
    });
    
    // Focus on first invalid field
    if (!isValid) {
      const firstError = form.querySelector('.form-control.is-invalid, .form-control[aria-invalid="true"]');
      if (firstError) {
        firstError.focus();
      }
    }
    
    return isValid;
  }

  validateField(input) {
    const validators = this.getValidators(input);
    let isValid = true;
    let errorMessage = '';
    
    // Skip validation for hidden fields
    if (input.type === 'hidden' || !input.offsetParent) {
      return true;
    }
    
    for (const validator of validators) {
      const result = validator.validate(input.value, input);
      if (!result.valid) {
        isValid = false;
        errorMessage = result.message;
        break;
      }
    }
    
    if (isValid) {
      this.showFieldSuccess(input);
    } else {
      this.showFieldError(input, errorMessage);
    }
    
    return isValid;
  }

  getValidators(input) {
    const validators = [];
    
    // Required validation
    if (input.hasAttribute('required') || input.dataset.required === 'true') {
      validators.push({
        validate: (value) => ({
          valid: value.trim() !== '',
          message: 'This field is required'
        })
      });
    }
    
    // Email validation
    if (input.type === 'email') {
      validators.push({
        validate: (value) => {
          if (!value) return { valid: true };
          const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
          return {
            valid: emailRegex.test(value),
            message: 'Please enter a valid email address'
          };
        }
      });
    }
    
    // URL validation
    if (input.type === 'url') {
      validators.push({
        validate: (value) => {
          if (!value) return { valid: true };
          try {
            new URL(value);
            return { valid: true };
          } catch {
            return {
              valid: false,
              message: 'Please enter a valid URL'
            };
          }
        }
      });
    }
    
    // Phone validation
    if (input.type === 'tel' || input.dataset.validate === 'phone') {
      validators.push({
        validate: (value) => {
          if (!value) return { valid: true };
          const phoneRegex = /^[\+]?[1-9][\d]{0,15}$/;
          return {
            valid: phoneRegex.test(value.replace(/[\s\-\(\)]/g, '')),
            message: 'Please enter a valid phone number'
          };
        }
      });
    }
    
    // Length validation
    if (input.minLength) {
      validators.push({
        validate: (value) => ({
          valid: value.length >= input.minLength,
          message: `Must be at least ${input.minLength} characters long`
        })
      });
    }
    
    if (input.maxLength) {
      validators.push({
        validate: (value) => ({
          valid: value.length <= input.maxLength,
          message: `Must be no more than ${input.maxLength} characters long`
        })
      });
    }
    
    // Number validation
    if (input.type === 'number') {
      validators.push({
        validate: (value) => {
          if (!value) return { valid: true };
          const num = parseFloat(value);
          if (isNaN(num)) {
            return { valid: false, message: 'Please enter a valid number' };
          }
          
          if (input.min && num < parseFloat(input.min)) {
            return { valid: false, message: `Must be at least ${input.min}` };
          }
          
          if (input.max && num > parseFloat(input.max)) {
            return { valid: false, message: `Must be no more than ${input.max}` };
          }
          
          return { valid: true };
        }
      });
    }
    
    // Pattern validation
    if (input.pattern) {
      validators.push({
        validate: (value) => {
          if (!value) return { valid: true };
          const regex = new RegExp(input.pattern);
          return {
            valid: regex.test(value),
            message: input.title || 'Please match the requested format'
          };
        }
      });
    }
    
    // Custom validation
    if (input.dataset.validate) {
      const customValidator = this.getCustomValidator(input.dataset.validate);
      if (customValidator) {
        validators.push(customValidator);
      }
    }
    
    return validators;
  }

  getCustomValidator(type) {
    const customValidators = {
      'password-confirmation': {
        validate: (value, input) => {
          const passwordField = input.form.querySelector('input[type="password"]:not([data-validate="password-confirmation"])');
          if (!passwordField) return { valid: true };
          
          return {
            valid: value === passwordField.value,
            message: 'Passwords do not match'
          };
        }
      },
      
      'csv-file': {
        validate: (value, input) => {
          if (!input.files || input.files.length === 0) {
            return { valid: true };
          }
          
          const file = input.files[0];
          const maxSize = 10 * 1024 * 1024; // 10MB
          
          if (file.size > maxSize) {
            return { valid: false, message: 'File size must be less than 10MB' };
          }
          
          if (!file.name.endsWith('.csv') && file.type !== 'text/csv') {
            return { valid: false, message: 'Please select a CSV file' };
          }
          
          return { valid: true };
        }
      }
    };
    
    return customValidators[type];
  }

  showFieldError(input, message) {
    this.clearFieldError(input);
    
    input.classList.add('is-invalid');
    input.setAttribute('aria-invalid', 'true');
    
    const errorDiv = document.createElement('div');
    errorDiv.className = 'invalid-feedback mt-1 text-sm text-red-600';
    errorDiv.textContent = message;
    errorDiv.id = `${input.id || input.name}-error`;
    
    input.setAttribute('aria-describedby', errorDiv.id);
    
    // Insert after the input or its wrapper
    const wrapper = input.closest('.form-group') || input.parentNode;
    wrapper.appendChild(errorDiv);
  }

  showFieldSuccess(input) {
    this.clearFieldError(input);
    
    input.classList.remove('is-invalid');
    input.classList.add('is-valid');
    input.setAttribute('aria-invalid', 'false');
  }

  clearFieldError(input) {
    input.classList.remove('is-invalid', 'is-valid');
    input.removeAttribute('aria-invalid');
    input.removeAttribute('aria-describedby');
    
    const existingError = input.closest('.form-group')?.querySelector('.invalid-feedback') ||
                         input.parentNode.querySelector('.invalid-feedback');
    if (existingError) {
      existingError.remove();
    }
  }

  // Public method to manually validate a form
  static validateForm(formSelector) {
    const form = document.querySelector(formSelector);
    if (form) {
      const validator = new FormValidation();
      return validator.validateForm(form);
    }
    return false;
  }

  // Public method to manually validate a field
  static validateField(fieldSelector) {
    const field = document.querySelector(fieldSelector);
    if (field) {
      const validator = new FormValidation();
      return validator.validateField(field);
    }
    return false;
  }
}

// Initialize form validation
document.addEventListener('DOMContentLoaded', () => {
  new FormValidation();
});

// Re-initialize after Turbo navigations
document.addEventListener('turbo:load', () => {
  new FormValidation();
});

// Export for manual use
window.FormValidation = FormValidation;

export default FormValidation;
