extends CanvasLayer
@export var CRT: ColorRect
@export var VIGNETTE: ColorRect


func _process(delta):
	CRT.material.set_shader_parameter(
		"enable_scanline", Global.CONFIG.crt_shader_scanline)
	CRT.material.set_shader_parameter(
		"enable_chromatic_aberration", Global.CONFIG.crt_shader_chromatic_aberration)
	pass
