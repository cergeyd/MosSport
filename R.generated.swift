//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import Rswift
import UIKit

/// This `R` struct is generated and contains references to static resources.
struct R: Rswift.Validatable {
  fileprivate static let applicationLocale = hostingBundle.preferredLocalizations.first.flatMap { Locale(identifier: $0) } ?? Locale.current
  fileprivate static let hostingBundle = Bundle(for: R.Class.self)

  /// Find first language and bundle for which the table exists
  fileprivate static func localeBundle(tableName: String, preferredLanguages: [String]) -> (Foundation.Locale, Foundation.Bundle)? {
    // Filter preferredLanguages to localizations, use first locale
    var languages = preferredLanguages
      .map { Locale(identifier: $0) }
      .prefix(1)
      .flatMap { locale -> [String] in
        if hostingBundle.localizations.contains(locale.identifier) {
          if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
            return [locale.identifier, language]
          } else {
            return [locale.identifier]
          }
        } else if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
          return [language]
        } else {
          return []
        }
      }

    // If there's no languages, use development language as backstop
    if languages.isEmpty {
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages = [developmentLocalization]
      }
    } else {
      // Insert Base as second item (between locale identifier and languageCode)
      languages.insert("Base", at: 1)

      // Add development language as backstop
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages.append(developmentLocalization)
      }
    }

    // Find first language for which table exists
    // Note: key might not exist in chosen language (in that case, key will be shown)
    for language in languages {
      if let lproj = hostingBundle.url(forResource: language, withExtension: "lproj"),
         let lbundle = Bundle(url: lproj)
      {
        let strings = lbundle.url(forResource: tableName, withExtension: "strings")
        let stringsdict = lbundle.url(forResource: tableName, withExtension: "stringsdict")

        if strings != nil || stringsdict != nil {
          return (Locale(identifier: language), lbundle)
        }
      }
    }

    // If table is available in main bundle, don't look for localized resources
    let strings = hostingBundle.url(forResource: tableName, withExtension: "strings", subdirectory: nil, localization: nil)
    let stringsdict = hostingBundle.url(forResource: tableName, withExtension: "stringsdict", subdirectory: nil, localization: nil)

    if strings != nil || stringsdict != nil {
      return (applicationLocale, hostingBundle)
    }

    // If table is not found for requested languages, key will be shown
    return nil
  }

  /// Load string from Info.plist file
  fileprivate static func infoPlistString(path: [String], key: String) -> String? {
    var dict = hostingBundle.infoDictionary
    for step in path {
      guard let obj = dict?[step] as? [String: Any] else { return nil }
      dict = obj
    }
    return dict?[key] as? String
  }

  static func validate() throws {
    try intern.validate()
  }

  #if os(iOS) || os(tvOS)
  /// This `R.storyboard` struct is generated, and contains static references to 1 storyboards.
  struct storyboard {
    /// Storyboard `LaunchScreen`.
    static let launchScreen = _R.storyboard.launchScreen()

    #if os(iOS) || os(tvOS)
    /// `UIStoryboard(name: "LaunchScreen", bundle: ...)`
    static func launchScreen(_: Void = ()) -> UIKit.UIStoryboard {
      return UIKit.UIStoryboard(resource: R.storyboard.launchScreen)
    }
    #endif

    fileprivate init() {}
  }
  #endif

  /// This `R.color` struct is generated, and contains static references to 1 colors.
  struct color {
    /// Color `AccentColor`.
    static let accentColor = Rswift.ColorResource(bundle: R.hostingBundle, name: "AccentColor")

    #if os(iOS) || os(tvOS)
    /// `UIColor(named: "AccentColor", bundle: ..., traitCollection: ...)`
    @available(tvOS 11.0, *)
    @available(iOS 11.0, *)
    static func accentColor(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIColor? {
      return UIKit.UIColor(resource: R.color.accentColor, compatibleWith: traitCollection)
    }
    #endif

    #if os(watchOS)
    /// `UIColor(named: "AccentColor", bundle: ..., traitCollection: ...)`
    @available(watchOSApplicationExtension 4.0, *)
    static func accentColor(_: Void = ()) -> UIKit.UIColor? {
      return UIKit.UIColor(named: R.color.accentColor.name)
    }
    #endif

    fileprivate init() {}
  }

  /// This `R.file` struct is generated, and contains static references to 6 files.
  struct file {
    /// Resource file `OSMSportObjects.json`.
    static let osmSportObjectsJson = Rswift.FileResource(bundle: R.hostingBundle, name: "OSMSportObjects", pathExtension: "json")
    /// Resource file `departments.json`.
    static let departmentsJson = Rswift.FileResource(bundle: R.hostingBundle, name: "departments", pathExtension: "json")
    /// Resource file `mo.kml`.
    static let moKml = Rswift.FileResource(bundle: R.hostingBundle, name: "mo", pathExtension: "kml")
    /// Resource file `moscowPopulation.json`.
    static let moscowPopulationJson = Rswift.FileResource(bundle: R.hostingBundle, name: "moscowPopulation", pathExtension: "json")
    /// Resource file `sportObjects.json`.
    static let sportObjectsJson = Rswift.FileResource(bundle: R.hostingBundle, name: "sportObjects", pathExtension: "json")
    /// Resource file `sportTypes.json`.
    static let sportTypesJson = Rswift.FileResource(bundle: R.hostingBundle, name: "sportTypes", pathExtension: "json")

    /// `bundle.url(forResource: "OSMSportObjects", withExtension: "json")`
    static func osmSportObjectsJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.osmSportObjectsJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "departments", withExtension: "json")`
    static func departmentsJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.departmentsJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "mo", withExtension: "kml")`
    static func moKml(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.moKml
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "moscowPopulation", withExtension: "json")`
    static func moscowPopulationJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.moscowPopulationJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "sportObjects", withExtension: "json")`
    static func sportObjectsJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.sportObjectsJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "sportTypes", withExtension: "json")`
    static func sportTypesJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.sportTypesJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    fileprivate init() {}
  }

  /// This `R.image` struct is generated, and contains static references to 7 images.
  struct image {
    /// Image `arrow-icon`.
    static let arrowIcon = Rswift.ImageResource(bundle: R.hostingBundle, name: "arrow-icon")
    /// Image `iTunesArtwork`.
    static let iTunesArtwork = Rswift.ImageResource(bundle: R.hostingBundle, name: "iTunesArtwork")
    /// Image `icon-error`.
    static let iconError = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon-error")
    /// Image `launchLogo`.
    static let launchLogo = Rswift.ImageResource(bundle: R.hostingBundle, name: "launchLogo")
    /// Image `location-pin`.
    static let locationPin = Rswift.ImageResource(bundle: R.hostingBundle, name: "location-pin")
    /// Image `logo`.
    static let logo = Rswift.ImageResource(bundle: R.hostingBundle, name: "logo")
    /// Image `warning`.
    static let warning = Rswift.ImageResource(bundle: R.hostingBundle, name: "warning")

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "arrow-icon", bundle: ..., traitCollection: ...)`
    static func arrowIcon(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.arrowIcon, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "iTunesArtwork", bundle: ..., traitCollection: ...)`
    static func iTunesArtwork(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.iTunesArtwork, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "icon-error", bundle: ..., traitCollection: ...)`
    static func iconError(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.iconError, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "launchLogo", bundle: ..., traitCollection: ...)`
    static func launchLogo(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.launchLogo, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "location-pin", bundle: ..., traitCollection: ...)`
    static func locationPin(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.locationPin, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "logo", bundle: ..., traitCollection: ...)`
    static func logo(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.logo, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "warning", bundle: ..., traitCollection: ...)`
    static func warning(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.warning, compatibleWith: traitCollection)
    }
    #endif

    fileprivate init() {}
  }

  /// This `R.info` struct is generated, and contains static references to 1 properties.
  struct info {
    struct uiApplicationSceneManifest {
      static let _key = "UIApplicationSceneManifest"
      static let uiApplicationSupportsMultipleScenes = false

      fileprivate init() {}
    }

    fileprivate init() {}
  }

  /// This `R.nib` struct is generated, and contains static references to 8 nibs.
  struct nib {
    /// Nib `CalculateSettingsCell`.
    static let calculateSettingsCell = _R.nib._CalculateSettingsCell()
    /// Nib `CalculatedAreaCell`.
    static let calculatedAreaCell = _R.nib._CalculatedAreaCell()
    /// Nib `CalculatedTypeCell`.
    static let calculatedTypeCell = _R.nib._CalculatedTypeCell()
    /// Nib `DetailCell`.
    static let detailCell = _R.nib._DetailCell()
    /// Nib `DetailRegionCell`.
    static let detailRegionCell = _R.nib._DetailRegionCell()
    /// Nib `OSMSettingsCell`.
    static let osmSettingsCell = _R.nib._OSMSettingsCell()
    /// Nib `SearchHeaderView`.
    static let searchHeaderView = _R.nib._SearchHeaderView()
    /// Nib `SportObjectCell`.
    static let sportObjectCell = _R.nib._SportObjectCell()

    #if os(iOS) || os(tvOS)
    /// `UINib(name: "CalculateSettingsCell", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.calculateSettingsCell) instead")
    static func calculateSettingsCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.calculateSettingsCell)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UINib(name: "CalculatedAreaCell", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.calculatedAreaCell) instead")
    static func calculatedAreaCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.calculatedAreaCell)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UINib(name: "CalculatedTypeCell", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.calculatedTypeCell) instead")
    static func calculatedTypeCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.calculatedTypeCell)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UINib(name: "DetailCell", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.detailCell) instead")
    static func detailCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.detailCell)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UINib(name: "DetailRegionCell", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.detailRegionCell) instead")
    static func detailRegionCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.detailRegionCell)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UINib(name: "OSMSettingsCell", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.osmSettingsCell) instead")
    static func osmSettingsCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.osmSettingsCell)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UINib(name: "SearchHeaderView", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.searchHeaderView) instead")
    static func searchHeaderView(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.searchHeaderView)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UINib(name: "SportObjectCell", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.sportObjectCell) instead")
    static func sportObjectCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.sportObjectCell)
    }
    #endif

    static func calculateSettingsCell(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> CalculateSettingsCell? {
      return R.nib.calculateSettingsCell.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? CalculateSettingsCell
    }

    static func calculatedAreaCell(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> CalculatedAreaCell? {
      return R.nib.calculatedAreaCell.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? CalculatedAreaCell
    }

    static func calculatedTypeCell(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> CalculatedTypeCell? {
      return R.nib.calculatedTypeCell.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? CalculatedTypeCell
    }

    static func detailCell(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> DetailCell? {
      return R.nib.detailCell.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? DetailCell
    }

    static func detailRegionCell(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> DetailRegionCell? {
      return R.nib.detailRegionCell.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? DetailRegionCell
    }

    static func osmSettingsCell(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> OSMSettingsCell? {
      return R.nib.osmSettingsCell.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? OSMSettingsCell
    }

    static func searchHeaderView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> UIKit.UIView? {
      return R.nib.searchHeaderView.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
    }

    static func sportObjectCell(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> SportObjectCell? {
      return R.nib.sportObjectCell.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? SportObjectCell
    }

    fileprivate init() {}
  }

  /// This `R.reuseIdentifier` struct is generated, and contains static references to 7 reuse identifiers.
  struct reuseIdentifier {
    /// Reuse identifier `CalculateSettingsCell`.
    static let calculateSettingsCell: Rswift.ReuseIdentifier<CalculateSettingsCell> = Rswift.ReuseIdentifier(identifier: "CalculateSettingsCell")
    /// Reuse identifier `CalculatedAreaCell`.
    static let calculatedAreaCell: Rswift.ReuseIdentifier<CalculatedAreaCell> = Rswift.ReuseIdentifier(identifier: "CalculatedAreaCell")
    /// Reuse identifier `CalculatedTypeCell`.
    static let calculatedTypeCell: Rswift.ReuseIdentifier<CalculatedTypeCell> = Rswift.ReuseIdentifier(identifier: "CalculatedTypeCell")
    /// Reuse identifier `DetailCell`.
    static let detailCell: Rswift.ReuseIdentifier<DetailCell> = Rswift.ReuseIdentifier(identifier: "DetailCell")
    /// Reuse identifier `DetailRegionCell`.
    static let detailRegionCell: Rswift.ReuseIdentifier<DetailRegionCell> = Rswift.ReuseIdentifier(identifier: "DetailRegionCell")
    /// Reuse identifier `OSMSettingsCell`.
    static let osmSettingsCell: Rswift.ReuseIdentifier<OSMSettingsCell> = Rswift.ReuseIdentifier(identifier: "OSMSettingsCell")
    /// Reuse identifier `SportObjectCell`.
    static let sportObjectCell: Rswift.ReuseIdentifier<SportObjectCell> = Rswift.ReuseIdentifier(identifier: "SportObjectCell")

    fileprivate init() {}
  }

  /// This `R.string` struct is generated, and contains static references to 1 localization tables.
  struct string {
    /// This `R.string.errors` struct is generated, and contains static references to 2 localization keys.
    struct errors {
      /// Value: Ошибка сериализации
      static let errorSerialization = Rswift.StringResource(key: "error.serialization", tableName: "Errors", bundle: R.hostingBundle, locales: [], comment: nil)
      /// Value: Ошибка сериализации в данные
      static let errorSerializationData = Rswift.StringResource(key: "error.serialization.data", tableName: "Errors", bundle: R.hostingBundle, locales: [], comment: nil)

      /// Value: Ошибка сериализации
      static func errorSerialization(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("error.serialization", tableName: "Errors", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Errors", preferredLanguages: preferredLanguages) else {
          return "error.serialization"
        }

        return NSLocalizedString("error.serialization", tableName: "Errors", bundle: bundle, comment: "")
      }

      /// Value: Ошибка сериализации в данные
      static func errorSerializationData(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("error.serialization.data", tableName: "Errors", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "Errors", preferredLanguages: preferredLanguages) else {
          return "error.serialization.data"
        }

        return NSLocalizedString("error.serialization.data", tableName: "Errors", bundle: bundle, comment: "")
      }

      fileprivate init() {}
    }

    fileprivate init() {}
  }

  fileprivate struct intern: Rswift.Validatable {
    fileprivate static func validate() throws {
      try _R.validate()
    }

    fileprivate init() {}
  }

  fileprivate class Class {}

  fileprivate init() {}
}

struct _R: Rswift.Validatable {
  static func validate() throws {
    #if os(iOS) || os(tvOS)
    try storyboard.validate()
    #endif
  }

  #if os(iOS) || os(tvOS)
  struct nib {
    struct _CalculateSettingsCell: Rswift.NibResourceType, Rswift.ReuseIdentifierType {
      typealias ReusableType = CalculateSettingsCell

      let bundle = R.hostingBundle
      let identifier = "CalculateSettingsCell"
      let name = "CalculateSettingsCell"

      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> CalculateSettingsCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? CalculateSettingsCell
      }

      fileprivate init() {}
    }

    struct _CalculatedAreaCell: Rswift.NibResourceType, Rswift.ReuseIdentifierType {
      typealias ReusableType = CalculatedAreaCell

      let bundle = R.hostingBundle
      let identifier = "CalculatedAreaCell"
      let name = "CalculatedAreaCell"

      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> CalculatedAreaCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? CalculatedAreaCell
      }

      fileprivate init() {}
    }

    struct _CalculatedTypeCell: Rswift.NibResourceType, Rswift.ReuseIdentifierType {
      typealias ReusableType = CalculatedTypeCell

      let bundle = R.hostingBundle
      let identifier = "CalculatedTypeCell"
      let name = "CalculatedTypeCell"

      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> CalculatedTypeCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? CalculatedTypeCell
      }

      fileprivate init() {}
    }

    struct _DetailCell: Rswift.NibResourceType, Rswift.ReuseIdentifierType {
      typealias ReusableType = DetailCell

      let bundle = R.hostingBundle
      let identifier = "DetailCell"
      let name = "DetailCell"

      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> DetailCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? DetailCell
      }

      fileprivate init() {}
    }

    struct _DetailRegionCell: Rswift.NibResourceType, Rswift.ReuseIdentifierType {
      typealias ReusableType = DetailRegionCell

      let bundle = R.hostingBundle
      let identifier = "DetailRegionCell"
      let name = "DetailRegionCell"

      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> DetailRegionCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? DetailRegionCell
      }

      fileprivate init() {}
    }

    struct _OSMSettingsCell: Rswift.NibResourceType, Rswift.ReuseIdentifierType {
      typealias ReusableType = OSMSettingsCell

      let bundle = R.hostingBundle
      let identifier = "OSMSettingsCell"
      let name = "OSMSettingsCell"

      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> OSMSettingsCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? OSMSettingsCell
      }

      fileprivate init() {}
    }

    struct _SearchHeaderView: Rswift.NibResourceType {
      let bundle = R.hostingBundle
      let name = "SearchHeaderView"

      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
      }

      fileprivate init() {}
    }

    struct _SportObjectCell: Rswift.NibResourceType, Rswift.ReuseIdentifierType {
      typealias ReusableType = SportObjectCell

      let bundle = R.hostingBundle
      let identifier = "SportObjectCell"
      let name = "SportObjectCell"

      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> SportObjectCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? SportObjectCell
      }

      fileprivate init() {}
    }

    fileprivate init() {}
  }
  #endif

  #if os(iOS) || os(tvOS)
  struct storyboard: Rswift.Validatable {
    static func validate() throws {
      #if os(iOS) || os(tvOS)
      try launchScreen.validate()
      #endif
    }

    #if os(iOS) || os(tvOS)
    struct launchScreen: Rswift.StoryboardResourceWithInitialControllerType, Rswift.Validatable {
      typealias InitialController = UIKit.UIViewController

      let bundle = R.hostingBundle
      let name = "LaunchScreen"

      static func validate() throws {
        if UIKit.UIImage(named: "launchLogo", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'launchLogo' is used in storyboard 'LaunchScreen', but couldn't be loaded.") }
        if #available(iOS 11.0, tvOS 11.0, *) {
        }
      }

      fileprivate init() {}
    }
    #endif

    fileprivate init() {}
  }
  #endif

  fileprivate init() {}
}
