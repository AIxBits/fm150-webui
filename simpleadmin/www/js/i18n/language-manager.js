class LanguageManager {
    constructor() {
        this.currentLang = localStorage.getItem('preferred_language') || this.getBrowserLanguage();
        this.translations = {
            'en': enTranslations,
            'zh': zhTranslations
        };
        this.supportedLanguages = [
            { code: 'en', name: 'English' },
            { code: 'zh', name: '中文' }
        ];
    }

    getBrowserLanguage() {
        const lang = navigator.language.split('-')[0];
        return this.translations[lang] ? lang : 'en';
    }

    setLanguage(lang) {
        if (this.translations[lang]) {
            this.currentLang = lang;
            localStorage.setItem('preferred_language', lang);
            this.updatePageContent();
            return true;
        }
        return false;
    }

    translate(key) {
        return this.translations[this.currentLang][key] || this.translations['en'][key] || key;
    }

    updatePageContent() {
        document.querySelectorAll('[data-i18n]').forEach(element => {
            const key = element.getAttribute('data-i18n');
            if (element.tagName === 'INPUT' && element.type === 'placeholder') {
                element.placeholder = this.translate(key);
            } else {
                element.textContent = this.translate(key);
            }
        });

        // 触发自定义事件通知语言变更
        window.dispatchEvent(new CustomEvent('languageChanged', {
            detail: { language: this.currentLang }
        }));
    }

    getCurrentLanguage() {
        return this.currentLang;
    }

    getSupportedLanguages() {
        return this.supportedLanguages;
    }
}

// 创建全局语言管理器实例
window.languageManager = new LanguageManager();

// 当DOM加载完成后初始化语言
document.addEventListener('DOMContentLoaded', () => {
    window.languageManager.updatePageContent();
});
