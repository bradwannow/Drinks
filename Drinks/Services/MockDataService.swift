import Foundation

enum MockDataService {
    private static func url(_ path: String) -> URL {
        URL(string: path)!
    }

    static let featuredCocktail = Cocktail(
        name: "Midnight Vesper",
        description: "Gin, vodka, and Lillet Blanc with a lemon twist — the house signature at Velvet Room.",
        imageURL: url("https://images.unsplash.com/photo-1514362545857-3bc165c4d737?w=800&q=80"),
        barName: "Velvet Room",
        spirit: "Gin",
        isSeasonal: false,
        isFeatured: true,
        isTrending: true
    )

    static let cocktails: [Cocktail] = [
        featuredCocktail,
        Cocktail(
            name: "Smoked Old Fashioned",
            description: "Bourbon, demerara, Angostura, cherry wood smoke.",
            imageURL: url("https://images.unsplash.com/photo-1470337458703-46ad1756a187?w=800&q=80"),
            barName: "The Copper Still",
            spirit: "Bourbon",
            isSeasonal: true,
            isTrending: true
        ),
        Cocktail(
            name: "Garden Spritz",
            description: "Elderflower, prosecco, cucumber, fresh basil.",
            imageURL: url("https://images.unsplash.com/photo-1551538826-4c7acaaef387?w=800&q=80"),
            barName: "Botanica Bar",
            spirit: "Aperitif",
            isSeasonal: true,
            isTrending: true
        ),
        Cocktail(
            name: "Paloma Rosa",
            description: "Reposado tequila, grapefruit, hibiscus, lime salt rim.",
            imageURL: url("https://images.unsplash.com/photo-1546171753-97d0dbd11023?w=800&q=80"),
            barName: "Casa Nocturna",
            spirit: "Tequila",
            isTrending: true
        )
    ]

    static let trendingBars: [Bar] = [
        Bar(
            name: "Velvet Room",
            neighborhood: "West Village",
            tagline: "Speakeasy classics, candlelit booths",
            rating: 4.8,
            imageURL: url("https://images.unsplash.com/photo-1572116469694-31de07792adf?w=600&q=80"),
            latitude: 40.7336,
            longitude: -74.0027,
            isTrending: true,
            isFeatured: true
        ),
        Bar(
            name: "The Copper Still",
            neighborhood: "Chelsea",
            tagline: "Whiskey-forward, live jazz nightly",
            rating: 4.7,
            imageURL: url("https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=600&q=80"),
            latitude: 40.7465,
            longitude: -74.0014,
            isTrending: true,
            isFeatured: true
        ),
        Bar(
            name: "Noir & Neat",
            neighborhood: "SoHo",
            tagline: "Minimalist cocktails, maximalist flavor",
            rating: 4.6,
            imageURL: url("https://images.unsplash.com/photo-1566417713940-b755a4550a42?w=600&q=80"),
            latitude: 40.7233,
            longitude: -74.0030,
            isTrending: true
        ),
        Bar(
            name: "Botanica Bar",
            neighborhood: "East Village",
            tagline: "Garden-to-glass seasonal menus",
            rating: 4.5,
            imageURL: url("https://images.unsplash.com/photo-1571249477469-303375066f11?w=600&q=80"),
            latitude: 40.7265,
            longitude: -73.9815,
            isTrending: true
        )
    ]

    static let happyHours: [HappyHour] = [
        HappyHour(
            barName: "Velvet Room",
            barImageURL: url("https://images.unsplash.com/photo-1572116469694-31de07792adf?w=600&q=80"),
            neighborhood: "West Village",
            timeRange: "5 – 7 PM",
            dealDescription: "$12 signature cocktails, half-off small plates",
            daysActive: "Mon – Thu"
        ),
        HappyHour(
            barName: "The Copper Still",
            barImageURL: url("https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=600&q=80"),
            neighborhood: "Chelsea",
            timeRange: "4 – 6 PM",
            dealDescription: "$8 well drinks, $6 draft beer",
            daysActive: "Daily"
        ),
        HappyHour(
            barName: "Casa Nocturna",
            barImageURL: url("https://images.unsplash.com/photo-1566417713940-b755a4550a42?w=600&q=80"),
            neighborhood: "Lower East Side",
            timeRange: "6 – 8 PM",
            dealDescription: "Two margaritas for $18, free chips & salsa",
            daysActive: "Tue – Fri"
        )
    ]

    static let nearbyBars: [Bar] = [
        Bar(
            name: "Harbor & Hops",
            neighborhood: "Tribeca",
            tagline: "Waterfront views, rotating tap list",
            rating: 4.4,
            imageURL: url("https://images.unsplash.com/photo-1572116469694-31de07792adf?w=600&q=80"),
            latitude: 40.7320,
            longitude: -74.0050
        ),
        Bar(
            name: "The Amber Lounge",
            neighborhood: "Greenwich Village",
            tagline: "Art deco interiors, classic martinis",
            rating: 4.3,
            imageURL: url("https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=600&q=80"),
            latitude: 40.7345,
            longitude: -74.0010
        ),
        Bar(
            name: "Lowlight Social",
            neighborhood: "West Village",
            tagline: "Late-night bites and natural wines",
            rating: 4.2,
            imageURL: url("https://images.unsplash.com/photo-1571249477469-303375066f11?w=600&q=80"),
            latitude: 40.7310,
            longitude: -74.0040
        )
    ]

    static let searchCategories = [
        "Cocktail Bars",
        "Speakeasies",
        "Rooftops",
        "Wine Bars",
        "Happy Hour",
        "Seasonal Menus"
    ]

    static let savedBars: [Bar] = Array(trendingBars.prefix(2))

    static let savedCocktails: [Cocktail] = Array(cocktails.dropFirst().prefix(2))
}
