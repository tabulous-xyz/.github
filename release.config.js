const commitAnalyzer = [
  "@semantic-release/commit-analyzer",
];

const releaseNotesGenerator = [
  "@semantic-release/release-notes-generator",
];

const github = '@semantic-release/github'

const npm = '@semantic-release/npm'

const git = ["@semantic-release/git", {
  "message": "v${nextRelease.version} [skip ci]",
  "assets": [
    'package.json', 
    'package-lock.json',
  ]
}];


module.exports = {
  branches: [
      'main'
  ],
  repositoryUrl: 'git@github.com:tabulous-xyz/workflow.git',

  plugins: [
      commitAnalyzer,
      releaseNotesGenerator,
      npm,
      github,
      [
          '@semantic-release/exec',
          {
            prepareCmd: './bin/release/prepare.sh ${nextRelease.version}',
            publishCmd: './bin/release/publish.sh ${nextRelease.version}'
          }
      ],
      git,
  ]
}
