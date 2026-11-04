extends CanvasLayer
@export var experience_manager:Node
@onready var progress_bar: ProgressBar = $MarginContainer/ProgressBar

func _ready() -> void:
    progress_bar.value=0
    experience_manager.experience_updated.connect(on_experience_update)
func on_experience_update(current_experience:float,target_experience:float):
    var percent=current_experience/target_experience
    progress_bar.value=percent
    #信号发射把当前经验和升级所需经验导入函数
