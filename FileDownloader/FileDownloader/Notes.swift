//
//  Notes.swift
//  FileDownloader
//
//  Created by Murad Ismayilov on 12.03.23.
//

// MARK: async: Indicates that a method or function is asynchronous. Using it lets you suspend execution until an asynchronous method returns a result.

// MARK: await: Indicates that your code might pause its execution while it waits for an async-annotated method or function to return.

// MARK: Task: A unit of asynchronous work. You can wait for a task to complete or cancel it before it finishes. Task executes the given closure in an asynchronous context so the compiler knows what code is safe (or unsafe) to write in that closure.

// MARK: To optimize shared resources such as CPU cores and memory, Swift splits up your code into logical units called partial tasks, or partials. These represent parts of the code you’d like to run asynchronously.

// MARK: Executors are similar to GCD queues, but they’re more powerful and lower-level. Additionally, they can quickly run tasks and completely hide complexity like order of execution, thread management and more.

// MARK: To declare a function as asynchronous, add the async keyword before throws or the return type. Call the function by prepending await and, if the function is throwing, try as well. Here’s an example:

func myFunction() async throws -> String {
  ""
}

// let myVar = try await myFunction()

// MARK: To make a computed property asynchronous, simply add async to the getter and access the value by prepending await, like so:

var myProperty: String {
  get async {
    ""
  }
}

// print(await myProperty)

// MARK: For closures, add async to the signature:

func myFunction(worker: (Int) async -> Int) -> Int {
  0
}

//myFunction {
//  return await computeNumbers($0)
//}

// MARK: You can use the following APIs to manually control a task’s execution:

// MARK: Task(priority:operation): Schedules operation for asynchronous execution with the given priority. It inherits defaults from the current synchronous context.

// MARK: Task.detached(priority:operation): Similar to Task(priority:operation), except that it doesn’t inherit the defaults of the calling context.

// MARK: Task.value: Waits for the task to complete, then returns its value, similarly to a promise in other languages.

// MARK: Task.isCancelled: Returns true if the task was canceled since the last suspension point. You can inspect this boolean to know when you should stop the execution of scheduled work.

// MARK: Task.checkCancellation(): Throws a CancellationError if the task is canceled. This lets the function use the error-handling infrastructure to yield execution.

// MARK: Task.sleep(nanoseconds:): Makes the task sleep for at least the given number of nanoseconds, but doesn’t block the thread while that happens.

// MARK: In the scenario here, Task runs on the actor that called it. To create the same task without it being a part of the actor, use Task.detached(priority:operation:).

// MARK: When our code creates a Task from the main thread, that task will run on the main thread, too. Therefore, you know you can update the app’s UI safely.

// MARK: You learned that every use of await is a suspension point, and your code might resume on a different thread. The first piece of your code runs on the main thread because the task initially runs on the main actor. But after the first await, your code can execute on any thread. You need to explicitly route any UI-driving code back to the main thread.

// MARK: MainActor is a type that runs code on the main thread. It’s the modern alternative to the well-known DispatchQueue.main, which you might have used in the past. While it gets the job done, using MainActor.run() too often results in code with many closures, making it hard to read. A more elegant solution is to use the @MainActor annotation, which lets you automatically route calls to given functions or properties to the main thread.

// MARK: AsyncSequence is a protocol describing a sequence that can produce elements asynchronously. Its surface API is identical to the Swift standard library’s Sequence, with one difference: You need to await the next element, since it might not be immediately available, as it would in a regular Sequence.

// MARK: The HTTP protocol lets a server define that it supports a capability called partial requests. If the server supports it, you can ask it to return a byte range of the response, instead of the entire response at once. To make things a little more interesting, you’ll support both standard and partial requests in the app.

// MARK: Using partial response functionality lets you split the file into parts and download them in parallel.


// MARK: You can, however, implement a finer-grained cancellation strategy for your task-based code by using the following Task APIs:
//Task.isCancelled: Returns true if the task is still alive but has been canceled since the last suspension point.
//Task.currentPriority: Returns the current task’s priority.
//Task.cancel(): Attempts to cancel the task and its child tasks.
//Task.checkCancellation(): Throws a CancellationError if the task is canceled, making it easier to exit a throwing context.
//Task.yield(): Suspends the execution of the current task, giving the system a chance to cancel it automatically to execute some other task with higher priority.

// MARK: So far, you wrote your async code inside a .task(...) view modifier, which is responsible for automatically canceling your code when the view disappears. But the actions for the download buttons aren’t in a .task(), so there’s nothing to cancel your async operations.

// MARK: Each asynchronous task executes in its own context, which consists of its priority, actor and more. But don’t forget — a task can call other tasks. Because each might interact with many different functions, isolating shared data at runtime can be difficult. To address this, Swift offers a new property wrapper that marks a given property as task-local. Think for a moment about injecting an object into the environment in SwiftUI, which makes the object available not only to the immediate View, but also to all of its child views. Similarly, binding a task-local value makes it available not only to the immediate task, but also to all its child tasks:

// MARK: The JPEG format allows for partially decoding images, but other formats, such as TIFF, don’t allow for partial preview. So you’ll only support partial preview for JPEG files.

// MARK: You’ll develop the following custom logic: If the user is downloading a JPEG image and cancels before it finishes, you’ll show the partially downloaded preview. For other image types, you’ll just abort the download.

// MARK: AsyncSequence is a protocol which resembles Sequence and allows you to iterate over a sequence of values asynchronously. You iterate over a sequence asynchronously by using the for await ... in syntax, or directly creating an AsyncIterator and awaiting its next() method in the context of a while loop. Task offers several APIs to check if the current task was canceled. If you want to throw an error upon cancellation, use Task.checkCancellation(). To safely check and implement custom cancellation logic, use Task.isCancelled. To bind a value to a task and all its children, use the @TaskLocal property wrapper along with withValue().
