/*! Cake da Bina — interactions (vanilla JS, sem dependências) */
(function () {
  'use strict';

  // Carregamento não-bloqueante das Google Fonts (defer elimina render-blocking)
  var fontLink = document.createElement('link');
  fontLink.rel = 'stylesheet';
  fontLink.href = 'https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;500;600;700&family=Lato:wght@300;400;700&display=swap';
  document.head.appendChild(fontLink);

  // Ano dinâmico no rodapé
  var yearEl = document.getElementById('year');
  if (yearEl) { yearEl.textContent = String(new Date().getFullYear()); }

  // Menu mobile
  var toggle = document.querySelector('.nav-toggle');
  var nav = document.getElementById('main-nav');
  if (toggle && nav) {
    toggle.addEventListener('click', function () {
      var open = nav.classList.toggle('is-open');
      toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
      toggle.setAttribute('aria-label', open ? 'Fechar menu de navegação' : 'Abrir menu de navegação');
    });

    // Fecha o menu ao clicar em um link (mobile)
    nav.addEventListener('click', function (e) {
      var t = e.target;
      if (t && t.tagName === 'A' && nav.classList.contains('is-open')) {
        nav.classList.remove('is-open');
        toggle.setAttribute('aria-expanded', 'false');
      }
    });
  }

  // Scroll suave para âncoras (com fallback para quando prefers-reduced-motion)
  var links = document.querySelectorAll('a[href^="#"]');
  links.forEach(function (link) {
    link.addEventListener('click', function (e) {
      var href = link.getAttribute('href');
      if (!href || href === '#') return;
      var target = document.querySelector(href);
      if (target) {
        e.preventDefault();
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
        // Atualiza histórico sem pulo
        history.pushState(null, '', href);
      }
    });
  });

  // ── LIGHTBOX ────────────────────────────────────────────────
  var lb        = document.getElementById('lightbox');
  var lbImg     = lb && lb.querySelector('.lightbox-img');
  var lbCaption = lb && lb.querySelector('.lightbox-caption');
  var lbClose   = lb && lb.querySelector('.lightbox-close');
  var lbTrigger = null;

  function openLightbox(src, alt) {
    lbImg.src             = src;
    lbImg.alt             = alt || '';
    lbCaption.textContent = alt || '';
    lb.hidden             = false;
    document.body.style.overflow = 'hidden';
    lbClose.focus();
  }

  function closeLightbox() {
    lb.hidden = true;
    document.body.style.overflow = '';
    lbImg.src = '';
    if (lbTrigger) { lbTrigger.focus(); lbTrigger = null; }
  }

  if (lb) {
    document.querySelectorAll('.card-media.zoomable').forEach(function (el) {
      el.addEventListener('click', function () {
        lbTrigger = el;
        openLightbox(el.dataset.lightbox, el.dataset.lightboxAlt);
      });
      el.addEventListener('keydown', function (e) {
        if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); el.click(); }
      });
    });

    lbClose.addEventListener('click', closeLightbox);

    lb.addEventListener('click', function (e) {
      if (e.target === lb || e.target === lb.querySelector('.lightbox-figure')) {
        closeLightbox();
      }
    });

    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && !lb.hidden) closeLightbox();
    });
  }

  // Revela progressivamente cards/seções com IntersectionObserver
  if ('IntersectionObserver' in window) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          io.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12 });
    document.querySelectorAll('.card, .contact-card, .about-facts > div').forEach(function (el) {
      el.classList.add('reveal');
      io.observe(el);
    });
  }
})();
