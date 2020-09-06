var dropdown = document.querySelector('.dropdown')
if (dropdown) {
  dropdown.addEventListener('click', function (event) {
    event.stopPropagation()
    dropdown.classList.toggle('is-active')
  })
}
