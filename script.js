
document.addEventListener('DOMContentLoaded', function() {
    const slides = document.querySelectorAll('.slide');
    const dots = document.querySelectorAll('.dot');
    const prevButton = document.querySelector('.prev');
    const nextButton = document.querySelector('.next');
    let currentSlide = 0;
    
    function showSlide(n) {
        slides.forEach(slide => slide.classList.remove('active'));
        dots.forEach(dot => dot.classList.remove('active'));
        
        currentSlide = (n + slides.length) % slides.length;
        slides[currentSlide].classList.add('active');
        dots[currentSlide].classList.add('active');
    }
    
    function nextSlide() {
        showSlide(currentSlide + 1);
    }
    
    function prevSlide() {
        showSlide(currentSlide - 1);
    }
    
    // Event listeners
    prevButton.addEventListener('click', prevSlide);
    nextButton.addEventListener('click', nextSlide);
    
    dots.forEach((dot, index) => {
        dot.addEventListener('click', () => showSlide(index));
    });
    
    // Auto advance slides every 5 seconds
    setInterval(nextSlide, 5000);
    
    // Initialize first slide
    showSlide(0);
});
