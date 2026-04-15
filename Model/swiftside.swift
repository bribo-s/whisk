//
//  swiftside.swift
//  whisk
//
//  Created by Brianna Shen on 2024-08-21.
//

import Foundation
import PythonKit

// Ensure Python environment is correctly set up
let sentimentAnalyzer = Python.import("vaderSentiment.vaderSentiment").SentimentIntensityAnalyzer()
let sentimentScores = sentimentAnalyzer.polarity_scores("Your text here")
print(sentimentScores)
