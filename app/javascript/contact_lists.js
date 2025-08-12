document.addEventListener('DOMContentLoaded', function() {
  // Elements
  const selectAllCheckbox = document.getElementById('select-all');
  const contactCheckboxes = document.querySelectorAll('.contact-checkbox');
  const bulkActions = document.getElementById('bulk-actions');
  const selectedCount = document.getElementById('selected-count');
  const clearSelectionBtn = document.getElementById('clear-selection');
  const addToExistingListBtn = document.getElementById('add-to-existing-list');
  const createNewListBtn = document.getElementById('create-new-list');
  const addToTargetListBtn = document.getElementById('add-to-target-list');
  const removeFromTargetListBtn = document.getElementById('remove-from-target-list');
  
  // Check if we're in list context (from URL params)
  const urlParams = new URLSearchParams(window.location.search);
  const targetListId = urlParams.get('list_id');
  
  // Modals
  const addToListModal = document.getElementById('add-to-list-modal');
  const createListModal = document.getElementById('create-list-modal');
  const modalCloses = document.querySelectorAll('.modal-close');
  
  // Forms
  const addToListForm = document.getElementById('add-to-list-form');
  const createListForm = document.getElementById('create-list-form');

  // Initialize selection state on page load
  updateSelectAllState();
  updateBulkActions();

  // Select All functionality
  if (selectAllCheckbox) {
    selectAllCheckbox.addEventListener('change', function() {
      const isChecked = this.checked;
      contactCheckboxes.forEach(checkbox => {
        checkbox.checked = isChecked;
      });
      updateBulkActions();
    });
  }

  // Individual checkbox functionality
  contactCheckboxes.forEach(checkbox => {
    checkbox.addEventListener('change', function() {
      updateSelectAllState();
      updateBulkActions();
    });
  });

  // Clear selection
  if (clearSelectionBtn) {
    clearSelectionBtn.addEventListener('click', function() {
      contactCheckboxes.forEach(checkbox => {
        checkbox.checked = false;
      });
      if (selectAllCheckbox) {
        selectAllCheckbox.checked = false;
      }
      updateBulkActions();
    });
  }

  // Show modals for general list operations
  if (addToExistingListBtn) {
    addToExistingListBtn.addEventListener('click', function() {
      showModal(addToListModal);
    });
  }

  if (createNewListBtn) {
    createNewListBtn.addEventListener('click', function() {
      showModal(createListModal);
    });
  }

  // Handle target list operations
  if (addToTargetListBtn) {
    addToTargetListBtn.addEventListener('click', function() {
      const selectedContactIds = getSelectedContactIds();
      if (selectedContactIds.length === 0) {
        alert('No contacts selected');
        return;
      }
      addContactsToList(targetListId, selectedContactIds);
    });
  }

  if (removeFromTargetListBtn) {
    removeFromTargetListBtn.addEventListener('click', function() {
      const selectedContactIds = getSelectedContactIds();
      if (selectedContactIds.length === 0) {
        alert('No contacts selected');
        return;
      }
      removeContactsFromList(targetListId, selectedContactIds);
    });
  }

  // Close modals
  modalCloses.forEach(closeBtn => {
    closeBtn.addEventListener('click', function() {
      hideAllModals();
    });
  });

  // Close modal when clicking outside
  window.addEventListener('click', function(event) {
    if (event.target.classList.contains('modal')) {
      hideAllModals();
    }
  });

  // Handle add to existing list form
  if (addToListForm) {
    addToListForm.addEventListener('submit', function(e) {
      e.preventDefault();
      const listId = document.getElementById('existing-list-select').value;
      const selectedContactIds = getSelectedContactIds();
      
      if (!listId) {
        alert('Please select a list');
        return;
      }
      
      if (selectedContactIds.length === 0) {
        alert('No contacts selected');
        return;
      }
      
      addContactsToList(listId, selectedContactIds);
    });
  }

  // Handle create new list form
  if (createListForm) {
    createListForm.addEventListener('submit', function(e) {
      e.preventDefault();
      const name = document.getElementById('new-list-name').value;
      const description = document.getElementById('new-list-description').value;
      const selectedContactIds = getSelectedContactIds();
      
      if (!name.trim()) {
        alert('Please enter a list name');
        return;
      }
      
      if (selectedContactIds.length === 0) {
        alert('No contacts selected');
        return;
      }
      
      createListWithContacts(name, description, selectedContactIds);
    });
  }

  // Helper functions
  function updateSelectAllState() {
    if (!selectAllCheckbox) return;
    
    const checkedCount = document.querySelectorAll('.contact-checkbox:checked').length;
    const totalCount = contactCheckboxes.length;
    
    selectAllCheckbox.checked = checkedCount === totalCount;
    selectAllCheckbox.indeterminate = checkedCount > 0 && checkedCount < totalCount;
  }

  function updateBulkActions() {
    const checkedCount = document.querySelectorAll('.contact-checkbox:checked').length;
    
    if (checkedCount > 0) {
      bulkActions.classList.remove('hidden');
      selectedCount.textContent = `${checkedCount} contact${checkedCount !== 1 ? 's' : ''} selected`;
    } else {
      bulkActions.classList.add('hidden');
    }
  }

  function getSelectedContactIds() {
    const checked = document.querySelectorAll('.contact-checkbox:checked');
    return Array.from(checked).map(checkbox => checkbox.value);
  }

  function showModal(modal) {
    modal.classList.remove('hidden');
    document.body.style.overflow = 'hidden';
  }

  function hideAllModals() {
    const modals = document.querySelectorAll('.modal');
    modals.forEach(modal => {
      modal.classList.add('hidden');
    });
    document.body.style.overflow = '';
  }

  function removeContactsFromList(listId, contactIds) {
    contactIds.forEach(contactId => {
      const formData = new FormData();
      
      fetch(`/admin/contact_list_memberships/${listId}_${contactId}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          // Uncheck the checkbox for this contact
          const checkbox = document.querySelector(`.contact-checkbox[value="${contactId}"]`);
          if (checkbox) {
            checkbox.checked = false;
          }
        }
      })
      .catch(error => {
        console.error('Error:', error);
      });
    });
    
    showNotification(`Removed ${contactIds.length} contact(s) from list`, 'success');
    clearSelection();
  }

  function addContactsToList(listId, contactIds) {
    const formData = new FormData();
    formData.append('list_id', listId);
    contactIds.forEach(id => {
      formData.append('contact_ids[]', id);
    });

    fetch('/admin/contact_list_memberships/bulk_add', {
      method: 'POST',
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        showNotification(data.message, 'success');
        clearSelection();
        hideAllModals();
      } else {
        showNotification(data.message, 'error');
      }
    })
    .catch(error => {
      console.error('Error:', error);
      showNotification('An error occurred', 'error');
    });
  }

  function createListWithContacts(name, description, contactIds) {
    const listData = {
      list: {
        name: name,
        description: description,
        is_active: true
      }
    };

    // First create the list
    fetch('/admin/lists', {
      method: 'POST',
      body: JSON.stringify(listData),
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      }
    })
    .then(response => {
      if (response.ok) {
        return response.json();
      } else {
        throw new Error('Failed to create list');
      }
    })
    .then(data => {
      // Now add contacts to the newly created list
      if (data.list && data.list.id) {
        addContactsToList(data.list.id, contactIds);
      } else {
        showNotification('List created successfully!', 'success');
        clearSelection();
        hideAllModals();
        // Reload page to show updated state
        setTimeout(() => window.location.reload(), 1000);
      }
    })
    .catch(error => {
      console.error('Error:', error);
      showNotification('Failed to create list', 'error');
    });
  }

  function clearSelection() {
    contactCheckboxes.forEach(checkbox => {
      checkbox.checked = false;
    });
    if (selectAllCheckbox) {
      selectAllCheckbox.checked = false;
    }
    updateBulkActions();
  }

  function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.innerHTML = `
      <div class="notification-content">
        <span>${message}</span>
        <button type="button" class="notification-close">&times;</button>
      </div>
    `;

    // Add to page
    document.body.appendChild(notification);

    // Auto remove after 5 seconds
    setTimeout(() => {
      if (notification.parentNode) {
        notification.parentNode.removeChild(notification);
      }
    }, 5000);

    // Close button functionality
    const closeBtn = notification.querySelector('.notification-close');
    if (closeBtn) {
      closeBtn.addEventListener('click', () => {
        if (notification.parentNode) {
          notification.parentNode.removeChild(notification);
        }
      });
    }
  }
});
