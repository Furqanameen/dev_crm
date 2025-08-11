// Table Interactions Module
class TableInteractions {
  constructor() {
    this.initializeTables();
  }

  initializeTables() {
    this.initializeSearch();
    this.initializeFilters();
    this.initializeSorting();
    this.initializeBulkActions();
    this.initializePagination();
  }

  initializeSearch() {
    const searchInputs = document.querySelectorAll('.search-input');
    
    searchInputs.forEach(input => {
      let debounceTimer;
      
      input.addEventListener('input', (e) => {
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(() => {
          this.performSearch(e.target.value, input);
        }, 300);
      });
    });
  }

  performSearch(query, input) {
    const table = input.closest('.admin-table-container').querySelector('.admin-table');
    const rows = table.querySelectorAll('tbody tr');
    
    if (!query.trim()) {
      rows.forEach(row => row.style.display = '');
      return;
    }
    
    const searchTerm = query.toLowerCase();
    
    rows.forEach(row => {
      const text = row.textContent.toLowerCase();
      row.style.display = text.includes(searchTerm) ? '' : 'none';
    });
    
    this.updateSearchResults(table, query);
  }

  updateSearchResults(table, query) {
    const tbody = table.querySelector('tbody');
    const visibleRows = tbody.querySelectorAll('tr:not([style*="display: none"])');
    
    // Remove existing no-results message
    const existingMessage = tbody.querySelector('.no-results-row');
    if (existingMessage) {
      existingMessage.remove();
    }
    
    if (visibleRows.length === 0 && query.trim()) {
      const colCount = table.querySelectorAll('thead th').length;
      const noResultsRow = document.createElement('tr');
      noResultsRow.className = 'no-results-row';
      noResultsRow.innerHTML = `
        <td colspan="${colCount}" class="text-center py-8 text-gray-500">
          <div class="flex flex-col items-center">
            <div class="icon icon-search icon-2xl text-gray-300 mb-2"></div>
            <p class="font-medium">No results found</p>
            <p class="text-sm">Try adjusting your search terms</p>
          </div>
        </td>
      `;
      tbody.appendChild(noResultsRow);
    }
  }

  initializeFilters() {
    const filterSelects = document.querySelectorAll('.filter-select');
    
    filterSelects.forEach(select => {
      select.addEventListener('change', (e) => {
        this.applyFilter(e.target.value, e.target.dataset.filterType, select);
      });
    });
  }

  applyFilter(value, filterType, select) {
    const table = select.closest('.admin-table-container').querySelector('.admin-table');
    const rows = table.querySelectorAll('tbody tr:not(.no-results-row)');
    
    if (!value || value === 'all') {
      rows.forEach(row => row.style.display = '');
      return;
    }
    
    rows.forEach(row => {
      const cell = row.querySelector(`[data-${filterType}]`);
      if (cell) {
        const cellValue = cell.dataset[filterType] || cell.textContent.trim();
        row.style.display = cellValue === value ? '' : 'none';
      }
    });
  }

  initializeSorting() {
    const sortableHeaders = document.querySelectorAll('.sortable-header');
    
    sortableHeaders.forEach(header => {
      header.addEventListener('click', () => {
        this.sortTable(header);
      });
      
      // Add cursor pointer
      header.style.cursor = 'pointer';
      
      // Add sort indicator
      if (!header.querySelector('.sort-indicator')) {
        const indicator = document.createElement('span');
        indicator.className = 'sort-indicator ml-1 text-gray-400';
        indicator.innerHTML = '↕';
        header.appendChild(indicator);
      }
    });
  }

  sortTable(header) {
    const table = header.closest('table');
    const tbody = table.querySelector('tbody');
    const rows = Array.from(tbody.querySelectorAll('tr:not(.no-results-row)'));
    const columnIndex = Array.from(header.parentNode.children).indexOf(header);
    const currentSort = header.dataset.sort || 'none';
    
    // Clear all other sort indicators
    table.querySelectorAll('.sortable-header').forEach(h => {
      if (h !== header) {
        h.dataset.sort = 'none';
        const indicator = h.querySelector('.sort-indicator');
        if (indicator) indicator.innerHTML = '↕';
      }
    });
    
    // Determine new sort direction
    let newSort;
    if (currentSort === 'none' || currentSort === 'desc') {
      newSort = 'asc';
    } else {
      newSort = 'desc';
    }
    
    header.dataset.sort = newSort;
    const indicator = header.querySelector('.sort-indicator');
    if (indicator) {
      indicator.innerHTML = newSort === 'asc' ? '↑' : '↓';
    }
    
    // Sort rows
    rows.sort((a, b) => {
      const aVal = a.children[columnIndex].textContent.trim();
      const bVal = b.children[columnIndex].textContent.trim();
      
      // Try to parse as numbers
      const aNum = parseFloat(aVal);
      const bNum = parseFloat(bVal);
      
      if (!isNaN(aNum) && !isNaN(bNum)) {
        return newSort === 'asc' ? aNum - bNum : bNum - aNum;
      }
      
      // Sort as strings
      return newSort === 'asc' ? aVal.localeCompare(bVal) : bVal.localeCompare(aVal);
    });
    
    // Re-append sorted rows
    rows.forEach(row => tbody.appendChild(row));
  }

  initializeBulkActions() {
    const masterCheckbox = document.querySelector('.bulk-select-all');
    const itemCheckboxes = document.querySelectorAll('.bulk-select-item');
    const bulkActionBar = document.querySelector('.bulk-action-bar');
    
    if (masterCheckbox) {
      masterCheckbox.addEventListener('change', (e) => {
        itemCheckboxes.forEach(checkbox => {
          checkbox.checked = e.target.checked;
        });
        this.updateBulkActionBar();
      });
    }
    
    itemCheckboxes.forEach(checkbox => {
      checkbox.addEventListener('change', () => {
        this.updateBulkActionBar();
        this.updateMasterCheckbox();
      });
    });
  }

  updateBulkActionBar() {
    const selectedItems = document.querySelectorAll('.bulk-select-item:checked');
    const bulkActionBar = document.querySelector('.bulk-action-bar');
    const selectedCount = document.querySelector('.selected-count');
    
    if (bulkActionBar) {
      if (selectedItems.length > 0) {
        bulkActionBar.style.display = 'flex';
        if (selectedCount) {
          selectedCount.textContent = selectedItems.length;
        }
      } else {
        bulkActionBar.style.display = 'none';
      }
    }
  }

  updateMasterCheckbox() {
    const masterCheckbox = document.querySelector('.bulk-select-all');
    const itemCheckboxes = document.querySelectorAll('.bulk-select-item');
    const checkedItems = document.querySelectorAll('.bulk-select-item:checked');
    
    if (masterCheckbox) {
      if (checkedItems.length === 0) {
        masterCheckbox.checked = false;
        masterCheckbox.indeterminate = false;
      } else if (checkedItems.length === itemCheckboxes.length) {
        masterCheckbox.checked = true;
        masterCheckbox.indeterminate = false;
      } else {
        masterCheckbox.checked = false;
        masterCheckbox.indeterminate = true;
      }
    }
  }

  initializePagination() {
    const paginationButtons = document.querySelectorAll('.pagination-btn[data-page]');
    
    paginationButtons.forEach(button => {
      button.addEventListener('click', (e) => {
        e.preventDefault();
        if (button.classList.contains('disabled')) return;
        
        const page = button.dataset.page;
        this.loadPage(page);
      });
    });
  }

  loadPage(page) {
    // This would typically make an AJAX request to load the new page
    // For now, we'll just update the URL and let Turbo handle it
    const url = new URL(window.location);
    url.searchParams.set('page', page);
    
    // Use Turbo to navigate
    if (window.Turbo) {
      Turbo.visit(url.toString());
    } else {
      window.location.href = url.toString();
    }
  }
}

// Initialize table interactions
document.addEventListener('DOMContentLoaded', () => {
  new TableInteractions();
});

// Re-initialize after Turbo navigations
document.addEventListener('turbo:load', () => {
  new TableInteractions();
});

export default TableInteractions;
