extends Node
func await_all(tweens) -> void:
	var futures = []
	for tween in tweens:
		futures.append(await tween_finished(tween))
	for future in futures:
		await future

func tween_finished(tween: PropertyTweener):
	await tween.finished
