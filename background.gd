extends ParallaxBackground


# Custom parallax background implimentation because we don't have a moving camera
func _process(delta):
	scroll_offset.y +=200 * delta
