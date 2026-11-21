// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"

// Ignore repeated clicks on the lazy-loading buttons while a load_more request
// is in flight: the Turbo Stream response replaces #load_more_buttons, which
// resets the guard, so the next click goes through. Without this, a double
// click would append the same chunk twice and duplicate rows in the table.
document.addEventListener("turbo:click", (event) => {
  const container = event.target.closest("#load_more_buttons")
  if (!container) return
  if (container.dataset.loading === "true") {
    event.preventDefault()
    return
  }
  container.dataset.loading = "true"
})
