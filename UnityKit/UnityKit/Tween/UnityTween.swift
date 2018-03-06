import MKTween

public typealias UnityTween = Tween
public typealias UnityTweenTiming = Timing

extension UnityTween {
    
    public static func move(_ gameObject: GameObject, to: Vector3, duration: TimeInterval, useLocal: Bool = false) -> OperationTween<Float> {
        
        let start = useLocal ? gameObject.transform.localPosition : gameObject.transform.position
        let end = to
        
        return Tween.shared.value(start: 0.0, end: 1.0, duration: duration).set(update: { (period) in
            
            let newPosition = start + ((end - start) * period.progress)
            
            if useLocal { gameObject.transform.localPosition = newPosition }
            else { gameObject.transform.position = newPosition }
        })
    }
}
