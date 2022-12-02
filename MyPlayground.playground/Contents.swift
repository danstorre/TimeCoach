import Combine


func startCountdown(completion: @escaping (Int) -> Void) {
    [1,2,3].forEach { i in
        completion(i)
    }
}

func getPublisher() -> AnyPublisher<Int, Error> {
    return Deferred {
        let currentValue = CurrentValueSubject<Int, Error>(0)
        
        startCountdown(completion: { time in
            currentValue.send(time)
        })
        
        return currentValue
    }
    .dropFirst()
    .eraseToAnyPublisher()
}

let mypublisher = getPublisher()

mypublisher.sink { _ in
} receiveValue: { time in
    print("time")
}

