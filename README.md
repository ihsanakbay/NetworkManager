# Swift Network Manager

## Usage example

```swift
enum Api: URLGenerator {
    case list
	case add(model: Model)
	var url: URL? {
		var components = URLComponents()
		components.scheme = "https"
		components.host = "/api/..."
		components.path = path
		return components.url
	}
}

extension Api {
	fileprivate var path: String {
		switch self {
		case .list:
			return "/api/list/all"
		case .add(let model):
			return "/api/..."
		}
	}
}

try await networkManager.fetch(api: Api.list, method: .get(), request: request)
```
