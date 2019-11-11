# VIPER Demo App

## Project Overview

To run this project requires `Xcode 11, Swift 5, iOS 13`

The project lives inside a workspace which is composed of two distinct Xcode projects, `BabylonApiService` and `BabylonDemoApp`. I selected the **VIPER** architecture for separating distinct logical domains. Dependency injection is used heavily across the application and this has come in handy in the unit tests as every dependency is a protocol making it easy to write mocks.Finally I have used CocoaPods to install my dependencies into the main workspace as well as installing my `BabylonApiService` framework into the workspace. `PromiseKit` is used for implementing business logic and `RXSwift/RXCocoa` is used for binding together the presentation layer to the view layer in the `Posts` module.

### Running the App

I recommend running this app on a device when testing as I have noticed that the networking behaviour when switching off wifi on a simulator differs to on a real iOS device. I have seen that sometimes it takes the simulator some time to realise that the wifi connection on the mac is back up and results in network requests failing for a little while before it finally connects. This does not occur when you run the app on a device making it easier to test the offline and error scenarios. Also please note I have hard coded the network request timeouts to 5 seconds in order to improve the UX when the device has no connection.

### Running Unit Tests

To run the `BabylonApiService` tests select the framework scheme and press `cmd + U`

To run the `BabylonDemoApp` tests select the app scheme and press `cmd + U`

### BabylonApiService Overview

This is a framework that essentially represents the networking component of `Entity` layer within the `VIPER` architecture. This project encapsulates all network communication parsing of data to JSON and JSON to structs as well as network errors. It provides an interface for clients to make requests to the back end API. Clients can request posts, comments and users and get those responses back in the immutable strongly typed form of Codable structs which are the entities consumed by client applications.

No application layer business logic or use cases exists in this framework project which is part of the motivation behind extracting this layer into its own module. It is intended to be a strict interface to the API and nothing more. This makes it reusable as it is not tied in any way to a particular application.  

Making it a module also makes it very clear what this service's responsibility is and encourages developers to consider if they should be importing this module into a file. For instance if I was to see `import BabylonApiService` inside `PostsCollectionViewCell` it would be considered a code smell as in `VIPER` the entities should never leak into the view.

This project also contains its own unit tests for verifying urls and parsing are correct.

### BabylongDemoApp Overview

#### Summary
There are two distinct VIPER modules inside the projects labelled as `Posts` and `Detail`. `Posts` contains the interactor, presenter, router, and views for the initial Posts list screen and `Detail` contains the equivalent classes for displaying the post details selected by the user. Both these screens handle displaying a loading spinner as well as an in page error message with retry button for retrying the request in the case there has been an error while loading the page. I utilised RXSwift in order to create reactive bindings between the `Posts` view and  presenter layers.  

I have used PromiseKit in my presenters to improve the readability and comprehension of asynchronous data flows and logical steps. I believe this makes the code much easier to follow and eliminates nested closures. I also added an extension inside the App project called `BabylonApi+PromiseKit.swift` which provides a promise based interface for the service api framework. I chose to do it this way to keep the service framework as vanilla as possible. This way if it ever gets shared consumers don't need to install `PromiseKit` as a dependency and can easily get started with it with minimal fuss.

I have also used `RXSwift` inside the unit tests in order to setup bindings between the test and the object under test for creating stub test scenarios with mock dependencies. `PromiseKit` is also utilised in the unit tests to test public functions that return promises. This makes it very clear what flow is being tested inside the test function. (See `PostsInteractorTests.swift` for instance)

I have used DI in all of the domains including the view controllers even thought they are loaded from a storyboard. This was achieved using the `instantiateViewController(identifier:, creator:)` on the `UIStoryboard` class in iOS SDK 13. I went with the approach to be able to easily define autolayout constraints in story board but still be able inject dependencies through the view controllers constructor rather than exposing its private properties.

#### Caching Approach
Currently the interactors depend on `FileInteractable`. This dependency is injected allowing the interactors to write json to the documents directory or read from it when there is no network connection. The json is loaded from disk as a fallback when the associated api call promise's catch error case. If there is no json cached to disk I display a generic error message to the user but this could later be enhanced to map the error cases to localised descriptions improving the messaging for users.

Due to the DI approach used and the simplicity of the intercactors due to the clean separation of concerns in the project, I am confident  it would be quite trivial to swap out `FileInteractable` with a different dependency later such as `DataBaseInteractable` for instance which could abstract an interface to a proper DB but also hiding away the implementation details such that developers could decide to change easily from CoreData to SQL later if they so wished.
