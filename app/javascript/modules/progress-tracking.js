// Progress Tracking Module
class ProgressTracking {
  constructor() {
    this.initializeProgressBars();
    this.initializeStatusPolling();
  }

  initializeProgressBars() {
    const progressBars = document.querySelectorAll('.progress-bar');
    
    progressBars.forEach(bar => {
      this.animateProgressBar(bar);
    });
  }

  animateProgressBar(bar) {
    const targetWidth = bar.dataset.progress || bar.style.width;
    const numericValue = parseFloat(targetWidth);
    
    if (isNaN(numericValue)) return;
    
    // Start from 0 and animate to target
    bar.style.width = '0%';
    
    // Use requestAnimationFrame for smooth animation
    let startTime = null;
    const duration = 1000; // 1 second
    
    const animate = (currentTime) => {
      if (startTime === null) startTime = currentTime;
      const elapsed = currentTime - startTime;
      const progress = Math.min(elapsed / duration, 1);
      
      // Easing function (ease-out)
      const easeOut = 1 - Math.pow(1 - progress, 3);
      const currentWidth = easeOut * numericValue;
      
      bar.style.width = `${currentWidth}%`;
      
      if (progress < 1) {
        requestAnimationFrame(animate);
      }
    };
    
    requestAnimationFrame(animate);
  }

  initializeStatusPolling() {
    const pollingElements = document.querySelectorAll('[data-poll-url]');
    
    pollingElements.forEach(element => {
      const pollUrl = element.dataset.pollUrl;
      const pollInterval = parseInt(element.dataset.pollInterval) || 5000;
      
      if (pollUrl) {
        this.startPolling(pollUrl, pollInterval, element);
      }
    });
  }

  startPolling(url, interval, element) {
    const poll = async () => {
      try {
        const response = await fetch(url, {
          headers: {
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest'
          }
        });
        
        if (response.ok) {
          const data = await response.json();
          this.updateProgress(data, element);
          
          // Continue polling if not completed
          if (!data.completed) {
            setTimeout(poll, interval);
          } else {
            this.handleCompletion(data, element);
          }
        }
      } catch (error) {
        console.error('Polling error:', error);
        // Retry after a longer interval
        setTimeout(poll, interval * 2);
      }
    };
    
    // Start polling after the initial interval
    setTimeout(poll, interval);
  }

  updateProgress(data, element) {
    // Update progress bar
    const progressBar = element.querySelector('.progress-bar-fill, .progress-bar');
    if (progressBar && data.progress !== undefined) {
      progressBar.style.width = `${data.progress}%`;
      
      // Update progress text
      const progressText = element.querySelector('.progress-percentage');
      if (progressText) {
        progressText.textContent = `${data.progress}%`;
      }
    }
    
    // Update status
    const statusElement = element.querySelector('.status-indicator');
    if (statusElement && data.status) {
      this.updateStatus(statusElement, data.status);
    }
    
    // Update statistics
    if (data.stats) {
      this.updateStats(data.stats, element);
    }
    
    // Update time remaining
    if (data.timeRemaining) {
      const timeElement = element.querySelector('.time-remaining');
      if (timeElement) {
        timeElement.textContent = this.formatTime(data.timeRemaining);
      }
    }
  }

  updateStatus(statusElement, status) {
    // Remove all status classes
    statusElement.className = statusElement.className.replace(/status-\w+/g, '');
    
    // Add new status class
    statusElement.classList.add(`status-${status}`);
    
    // Update status text
    const statusText = statusElement.querySelector('.status-text');
    if (statusText) {
      statusText.textContent = this.formatStatus(status);
    }
  }

  updateStats(stats, element) {
    Object.keys(stats).forEach(key => {
      const statElement = element.querySelector(`.stat-${key}`);
      if (statElement) {
        const valueElement = statElement.querySelector('.progress-stat-value, .stat-value');
        if (valueElement) {
          this.animateNumber(valueElement, stats[key]);
        }
      }
    });
  }

  animateNumber(element, targetValue) {
    const startValue = parseInt(element.textContent) || 0;
    const difference = targetValue - startValue;
    const duration = 500;
    let startTime = null;
    
    const animate = (currentTime) => {
      if (startTime === null) startTime = currentTime;
      const elapsed = currentTime - startTime;
      const progress = Math.min(elapsed / duration, 1);
      
      const currentValue = Math.round(startValue + (difference * progress));
      element.textContent = currentValue.toLocaleString();
      
      if (progress < 1) {
        requestAnimationFrame(animate);
      }
    };
    
    requestAnimationFrame(animate);
  }

  handleCompletion(data, element) {
    // Show completion message
    this.showNotification('Process completed successfully!', 'success');
    
    // Update final status
    const statusElement = element.querySelector('.status-indicator');
    if (statusElement) {
      this.updateStatus(statusElement, data.status || 'completed');
    }
    
    // Enable any disabled buttons
    const buttons = element.querySelectorAll('button[disabled]');
    buttons.forEach(button => {
      button.disabled = false;
    });
    
    // Trigger custom completion event
    element.dispatchEvent(new CustomEvent('progress:completed', { 
      detail: data 
    }));
  }

  formatStatus(status) {
    const statusMap = {
      'uploaded': 'Uploaded',
      'mapping': 'Mapping Columns',
      'validating': 'Validating Data',
      'importing': 'Importing',
      'completed': 'Completed',
      'failed': 'Failed'
    };
    
    return statusMap[status] || status.charAt(0).toUpperCase() + status.slice(1);
  }

  formatTime(seconds) {
    if (seconds < 60) {
      return `${Math.round(seconds)}s`;
    } else if (seconds < 3600) {
      const minutes = Math.floor(seconds / 60);
      const remainingSeconds = Math.round(seconds % 60);
      return `${minutes}m ${remainingSeconds}s`;
    } else {
      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);
      return `${hours}h ${minutes}m`;
    }
  }

  showNotification(message, type = 'info') {
    // This would integrate with the notifications module
    if (window.Notifications) {
      window.Notifications.show(message, type);
    } else {
      // Fallback to alert
      alert(message);
    }
  }
}

// Initialize progress tracking
document.addEventListener('DOMContentLoaded', () => {
  new ProgressTracking();
});

// Re-initialize after Turbo navigations
document.addEventListener('turbo:load', () => {
  new ProgressTracking();
});

export default ProgressTracking;
