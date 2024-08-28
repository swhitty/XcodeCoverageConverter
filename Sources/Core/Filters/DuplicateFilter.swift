//
//  DuplicateFilter.swift
//
//
//  Created by Thibault Wittemberg on 2020-06-01.
//

public extension Xccov.Filters.Packages {
    static func filterDuplicates(coverageReport: CoverageReport) -> CoverageReport {
        let targetsToKeep = coverageReport.targets.map(filterDuplicates)

        let adjusted = targetsToKeep.reduce(into: (coveredLines: 0, executableLines: 0)) {
            $0.coveredLines += $1.coveredLines
            $0.executableLines += $1.executableLines
        }
        let filteredCoverageReport = CoverageReport(
            executableLines: adjusted.executableLines,
            targets: targetsToKeep,
            lineCoverage: Double(adjusted.coveredLines) / Double(adjusted.executableLines),
            coveredLines: adjusted.coveredLines
        )

        return filteredCoverageReport
    }

    static func filterDuplicates(target: TargetCoverageReport) -> TargetCoverageReport {
        print("target**", target.name)
        var files = [String: FileCoverageReport]()

        for file in target.files {
            if let existing = files[file.path] {
                print("existing", file.path)
                if file.lineCoverage > existing.lineCoverage {
                    files[file.path] = file
                }
            } else {
                print("new", file.path)
                files[file.path] = file
            }
        }

        let filesToKeep = Array(files.values)
        let adjusted = filesToKeep.reduce(into: (coveredLines: 0, executableLines: 0)) {
            $0.coveredLines += $1.coveredLines
            $0.executableLines += $1.executableLines
        }
        return TargetCoverageReport(
            buildProductPath: target.buildProductPath,
            coveredLines: adjusted.coveredLines,
            executableLines: adjusted.executableLines,
            files: filesToKeep,
            lineCoverage: Double(adjusted.coveredLines) / Double(adjusted.executableLines),
            name: target.name
        )
    }
}
