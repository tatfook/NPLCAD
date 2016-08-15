window.onload = function(){
var panel = document.getElementById('panel'),
        menu = document.getElementById('menu'),
        showcode = document.getElementById('showcode'),
		runcode = document.getElementById('runcode'),
        selectFx = document.getElementById('selections-fx'),
        selectPos = document.getElementById('selections-pos'),
        // demo defaults
        effect = 'mfb-zoomin',
        pos = 'mfb-component--br';

    showcode.addEventListener('click', _toggleCode);
	runcode.addEventListener('click', _hiddeCode);

   

    function _toggleCode() {
      panel.classList.toggle('viewCode');
    }
	function _hiddeCode(){
		if(document.getElementById('viewCode')){
			panel.classList.toggle('viewCode');
		}
		else return
	}
    function switchEffect(e){
      effect = this.options[this.selectedIndex].value;
      renderMenu();
    }

    function switchPos(e){
      pos = this.options[this.selectedIndex].value;
      renderMenu();
    }

    function renderMenu() {
      menu.style.display = 'none';
      // ?:-)
      setTimeout(function() {
        menu.style.display = 'block';
        menu.className = pos + effect;
      },1);
    }
}