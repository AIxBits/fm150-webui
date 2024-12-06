class LanguageManager {
    constructor() {
        // 首先尝试从localStorage获取用户设置的语言
        // 如果没有，则使用浏览器语言
        this.currentLang = localStorage.getItem('preferred_language') || this.getBrowserLanguage();
        this.translations = {
            'en': enTranslations,
            'zh': zhTranslations
        };
        this.supportedLanguages = [
            { code: 'en', name: 'English' },
            { code: 'zh', name: '中文' }
        ];
        
        // 初始化时更新页面内容
        this.updatePageContent();
    }

    getBrowserLanguage() {
        // 获取完整的浏览器语言设置
        const fullLang = navigator.language.toLowerCase();
        
        // 检查是否是中文
        if (fullLang.startsWith('zh')) {
            return 'zh';
        }
        
        // 其他所有语言默认使用英文
        return 'en';
    }

    setLanguage(lang) {
        if (this.translations[lang]) {
            this.currentLang = lang;
            // 保存到localStorage以便持久化
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
