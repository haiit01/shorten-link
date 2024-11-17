import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["tabContent", "tabButton"];

  connect() {
    this.handleApi();
  }

  showTab(event) {
    const tabName = event.target.dataset.tabName;

    this.tabContentTargets.forEach(content => {
      content.classList.remove("active");
    });

    this.tabButtonTargets.forEach(button => {
      button.classList.remove("active");
    });

    const selectedTab = document.getElementById(tabName);
    if (selectedTab) {
      selectedTab.classList.add("active");
    }

    const activeButton = Array.from(this.tabButtonTargets).find(button => button.dataset.tabName === tabName);

    if (activeButton) {
      activeButton.classList.add("active");
    }
  }

  handleApi() {
    const encodeForm = this.element.querySelector('#encode-form');
    if (encodeForm) {
      encodeForm.addEventListener('submit', this.encodeSubmitHandler.bind(this));
    }

    const decodeForm = this.element.querySelector('#decode-form');
    if (decodeForm) {
      decodeForm.addEventListener('submit', this.decodeSubmitHandler.bind(this));
    }
  }

  encodeSubmitHandler(event) {
    event.preventDefault();
    
    const encodeForm = event.target;
    const urlInput = encodeForm.querySelector('input[name="original_link"]');
    const responseContainer = document.getElementById('encode-response');
    const originalLink = urlInput.value;

    fetch('/encode', {
      method: 'POST',
      body: JSON.stringify({ original_link: originalLink }),
      headers: { 'Content-Type': 'application/json' },
    })
    .then(response => {
      if (response.status === 200) {
        return response.json();
      } else {
        return response.json().then(data => {
          throw new Error(data.error || "Something went wrong");
        });
      }
    })
    .then(data => {
      responseContainer.innerHTML = `
        <div class="link-result">
          <span>Shortened URL: </span>
          <a id="shortened-url" href="${data.short_url}" target="_blank">
            ${data.short_url}
          </a>
          <button id="copy-button-encode">
            <img src="https://img.icons8.com/material-outlined/24/000000/copy.png" alt="Copy" />
          </button>
        </div>
        <span id="copy-success-encode">Copied!</span>
      `;

      const copyButton = document.getElementById("copy-button-encode");
      const shortenedUrl = document.getElementById("shortened-url");
      const copySuccess = document.getElementById("copy-success-encode");

      copyButton.addEventListener("click", () => {
        navigator.clipboard.writeText(shortenedUrl.href).then(() => {
          copySuccess.style.display = "inline";
          setTimeout(() => (copySuccess.style.display = "none"), 1500);
        });
      });
    })
    .catch(error => {
      responseContainer.innerHTML = `<p style="color: red;">${error.message}</p>`;
    });
  }

  decodeSubmitHandler(event) {
    event.preventDefault();
    
    const decodeForm = event.target;
    const urlInput = decodeForm.querySelector('input[name="short_link"]');
    const shortLink = urlInput.value;
    const responseContainer = document.getElementById('decode-response');

    fetch(`/decode?short_link=${encodeURIComponent(shortLink)}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      }
    })
    .then(response => {
      if (response.status === 200) {
        return response.json();
      } else {
        return response.json().then(data => {
          throw new Error(data.error || "Something went wrong");
        });
      }
    })
    .then(data => {
      responseContainer.innerHTML = `
        <div class="link-result">
          <span>Original URL: </span>
          <a id="original-url" href="${data.original_url}" target="_blank">
            ${data.original_url}
          </a>
          <button id="copy-button-decode">
            <img src="https://img.icons8.com/material-outlined/24/000000/copy.png" alt="Copy" />
          </button>
        </div>
        <span id="copy-success-decode">Copied!</span>
      `;

      const copyButton = document.getElementById("copy-button-decode");
      const originalUrl = document.getElementById("original-url");
      const copySuccess = document.getElementById("copy-success-decode");

      copyButton.addEventListener("click", () => {
        navigator.clipboard.writeText(originalUrl.href).then(() => {
          copySuccess.style.display = "inline";
          setTimeout(() => (copySuccess.style.display = "none"), 1500);
        });
      });
    })
    .catch(error => {
      responseContainer.innerHTML = `<p style="color: red;">${error.message}</p>`;
    });
  }
}
