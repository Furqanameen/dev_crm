// Method override support for Rails 8
// Handles DELETE, PATCH, PUT methods via hidden form fields

document.addEventListener('DOMContentLoaded', function() {
  // Handle links with method attribute
  document.addEventListener('click', function(event) {
    const link = event.target.closest('a[data-method]');
    if (!link) return;
    
    const method = link.dataset.method;
    if (method && method.toLowerCase() !== 'get') {
      event.preventDefault();
      
      const href = link.href;
      const csrfToken = document.querySelector('meta[name="csrf-token"]');
      
      if (link.dataset.confirm) {
        if (!confirm(link.dataset.confirm)) {
          return;
        }
      }
      
      // Create and submit a form with the proper method
      const form = document.createElement('form');
      form.method = 'POST';
      form.action = href;
      form.style.display = 'none';
      
      // Add CSRF token
      if (csrfToken) {
        const csrfInput = document.createElement('input');
        csrfInput.type = 'hidden';
        csrfInput.name = 'authenticity_token';
        csrfInput.value = csrfToken.content;
        form.appendChild(csrfInput);
      }
      
      // Add method override
      const methodInput = document.createElement('input');
      methodInput.type = 'hidden';
      methodInput.name = '_method';
      methodInput.value = method;
      form.appendChild(methodInput);
      
      document.body.appendChild(form);
      form.submit();
    }
  });
});
