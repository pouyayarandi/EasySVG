# EasySVG
**EasySVG** is a framework written in swift for loading vector assets in `UIImageView`. this framework uses `WebKit`'s `WKWebView` for loading vectors.

## Add to project
**cocoapods**
add this line to your Podfile:
```ruby
pod 'EasySVG'
```
and then run `pod install`

**manually**

also you can add this framework to your project by downloading the source.

## How to use
it's really simple. just add vector file to your project with drag and drop. then add the following code for your `UIImageView` in `ViewController`
```swift
imageView.setSVG("YOUR_VECTOR_NAME")
```
also this framework has some other features

## Other methods
you can call `setSVG()` method with other arguments:
* with url of vector file:
```swift
if let url = Bundle.main.url(forResource: "like", withExtension: "svg") {
    imageView.setSVG(url)
}
```
* with an optional overlay color:
```swift
imageView.setSVG("crown", withColor: .red)
```
## Cache vectors
EasySVG caches vectors for better performance. if you want to enable this feature you can add following code to your `AppDelegate`'s `didFinishLaunchingWithOptions` method:
```swift
EasySVG.allowCache = true
```
also you can remove cached vectors using `removeCache()` method
```swift
EasySVG.removeCache()
```
## Storyboard and XIB
in Storyboard and XIB you can use `EasyImageView` as an outlet. this class is subclass of `UIImageView` and you can use it instead of a normal image view.

add `EasyImageView` and `EasySVG` as class and module of your `UIImageView`
![identity inspector tab](http://uupload.ir/files/ufy2_screen_shot_2019-01-21_at_2.14.08_pm.png)

then set `EasyImageView` attributes in the attribute inspector tab
![attribute inspector tab](http://uupload.ir/files/cpag_screen_shot_2019-01-21_at_2.14.21_pm.png)

## Support us
support us with click on star icon. thanks ❤️

## License
MIT
