$(document).ready(function(){
	$('.product-image-wrapper').click(function(){
		var $imageHoverDiv = $(this).find('.image-hover');
		
		if($(this).attr('data-hover') == 'yes') {
			$imageHoverDiv.css({'display': 'none'});
			$(this).attr('data-hover', 'no');
			
		}
		else {
			$imageHoverDiv.css({'display' : 'block'});
			$(this).attr('data-hover', 'yes');
			
		}
	});
	$('.cart-item:last-child').css({'border-bottom-width:': '1px !important'})
});