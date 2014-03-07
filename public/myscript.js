$(document).ready(function(){

	$(".delete").click( function(e){
		answer = confirm("Are you sure you want to delete your account?")
		if(answer){
			return true;
		}else{
			e.preventDefault();
		}
		}
	);

});