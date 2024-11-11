# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "bootstrap", to: "https://unpkg.com/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
pin "@popperjs/core", to: "https://unpkg.com/@popperjs/core@2.11.6/dist/esm/index.js"
pin "filepond" # @4.32.1
pin_all_from "app/javascript/custom", under: "custom"
pin "filepond-plugin-image-preview" # @4.6.12
