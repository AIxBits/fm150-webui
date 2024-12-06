class LanguageManager {
    constructor() {
        this.translations = {
            'en': enTranslations,
            'zh': zhTranslations
        };
        this.initializeLanguage();
    }

    initializeLanguage() {
        const savedLang = localStorage.getItem('preferred_language');
        if (savedLang && this.translations[savedLang]) {
            this.currentLang = savedLang;
        } else {
            this.currentLang = this.getBrowserLanguage();
            localStorage.setItem('preferred_language', this.currentLang);
        }
        document.documentElement.lang = this.currentLang;
        this.updatePageContent();
    }

    getBrowserLanguage() {
        const fullLang = (navigator.language || navigator.userLanguage || 'en').toLowerCase();
        return fullLang.startsWith('zh') ? 'zh' : 'en';
    }

    setLanguage(lang) {
        if (this.translations[lang]) {
            this.currentLang = lang;
            localStorage.setItem('preferred_language', lang);
            document.documentElement.lang = lang;
            this.updatePageContent();
            window.dispatchEvent(new CustomEvent('languageChanged', {
                detail: { language: lang }
            }));
            return true;
        }
        return false;
    }

    translate(key) {
        const translation = this.translations[this.currentLang][key];
        return translation || this.translations['en'][key] || key;
    }

    updatePageContent() {
        document.querySelectorAll('[data-i18n]').forEach(element => {
            const key = element.getAttribute('data-i18n');
            const translation = this.translate(key);
            
            if (element.tagName === 'INPUT' && element.getAttribute('type') === 'placeholder') {
                element.placeholder = translation;
            } else {
                element.textContent = translation;
            }
        });
    }

    getCurrentLanguage() {
        return this.currentLang;
    }
}

document.addEventListener('DOMContentLoaded', () => {
    window.languageManager = new LanguageManager();
    
    const observer = new MutationObserver((mutations) => {
        mutations.forEach((mutation) => {
            if (mutation.addedNodes.length) {
                window.languageManager.updatePageContent();
            }
        });
    });
    
    observer.observe(document.body, {
        childList: true,
        subtree: true
    });
});
