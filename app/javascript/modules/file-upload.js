// File Upload Module
class FileUpload {
  constructor() {
    this.initializeFileUploads();
  }

  initializeFileUploads() {
    const fileUploads = document.querySelectorAll('.file-upload');
    
    fileUploads.forEach(upload => {
      const input = upload.querySelector('.file-upload-input');
      const label = upload.querySelector('.file-upload-label');
      
      if (!input || !label) return;
      
      // Handle file selection
      input.addEventListener('change', (e) => {
        this.handleFileSelect(e, label);
      });
      
      // Handle drag and drop
      this.setupDragAndDrop(label, input);
    });
  }

  handleFileSelect(event, label) {
    const files = event.target.files;
    if (files.length > 0) {
      const file = files[0];
      this.updateLabel(label, file);
      this.validateFile(file, event.target);
    }
  }

  updateLabel(label, file) {
    const fileName = file.name;
    const fileSize = this.formatFileSize(file.size);
    
    label.innerHTML = `
      <div class="flex items-center justify-center">
        <div class="icon icon-upload icon-lg text-primary-600 mr-3"></div>
        <div>
          <div class="font-medium text-gray-900">${fileName}</div>
          <div class="text-sm text-gray-500">${fileSize}</div>
        </div>
      </div>
    `;
    
    label.classList.add('bg-primary-50', 'border-primary-300');
    label.classList.remove('bg-gray-50', 'border-gray-300');
  }

  setupDragAndDrop(label, input) {
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
      label.addEventListener(eventName, this.preventDefaults, false);
    });

    ['dragenter', 'dragover'].forEach(eventName => {
      label.addEventListener(eventName, () => this.highlightDropArea(label), false);
    });

    ['dragleave', 'drop'].forEach(eventName => {
      label.addEventListener(eventName, () => this.unhighlightDropArea(label), false);
    });

    label.addEventListener('drop', (e) => this.handleDrop(e, input, label), false);
  }

  preventDefaults(e) {
    e.preventDefault();
    e.stopPropagation();
  }

  highlightDropArea(label) {
    label.classList.add('drag-over');
  }

  unhighlightDropArea(label) {
    label.classList.remove('drag-over');
  }

  handleDrop(e, input, label) {
    const dt = e.dataTransfer;
    const files = dt.files;

    if (files.length > 0) {
      input.files = files;
      this.handleFileSelect({ target: input }, label);
    }
  }

  validateFile(file, input) {
    const maxSize = 10 * 1024 * 1024; // 10MB
    const allowedTypes = ['text/csv', 'application/vnd.ms-excel'];
    
    if (file.size > maxSize) {
      this.showError(input, 'File size must be less than 10MB');
      return false;
    }
    
    if (!allowedTypes.includes(file.type) && !file.name.endsWith('.csv')) {
      this.showError(input, 'Please select a CSV file');
      return false;
    }
    
    this.clearError(input);
    return true;
  }

  showError(input, message) {
    this.clearError(input);
    
    const errorDiv = document.createElement('div');
    errorDiv.className = 'file-upload-error mt-2 text-sm text-red-600';
    errorDiv.textContent = message;
    
    input.closest('.file-upload').appendChild(errorDiv);
    input.classList.add('error');
  }

  clearError(input) {
    const existingError = input.closest('.file-upload').querySelector('.file-upload-error');
    if (existingError) {
      existingError.remove();
    }
    input.classList.remove('error');
  }

  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }
}

// Initialize file upload functionality
document.addEventListener('DOMContentLoaded', () => {
  new FileUpload();
});

// Re-initialize after Turbo navigations
document.addEventListener('turbo:load', () => {
  new FileUpload();
});

export default FileUpload;
