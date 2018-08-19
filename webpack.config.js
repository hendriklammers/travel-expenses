const path = require('path')
const webpack = require('webpack')
const merge = require('webpack-merge')
const autoprefixer = require('autoprefixer')
const CopyWebpackPlugin = require('copy-webpack-plugin')
const HTMLWebpackPlugin = require('html-webpack-plugin')
const CleanWebpackPlugin = require('clean-webpack-plugin')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const Dotenv = require('dotenv-webpack')

const MODE =
  process.env.npm_lifecycle_event === 'prod' ? 'production' : 'development'
const filename = MODE === 'production' ? '[name]-[hash].js' : 'index.js'

const common = {
  mode: MODE,
  entry: './src/index.js',
  output: {
    path: path.join(__dirname, 'dist'),
    filename: filename
  },
  plugins: [
    new HTMLWebpackPlugin({
      template: 'src/index.html',
      inject: 'body'
    }),
    new Dotenv()
  ],
  resolve: {
    modules: [path.join(__dirname, 'src'), 'node_modules'],
    extensions: ['.js', '.elm', '.scss', '.png']
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      },
      {
        test: /\.scss$/,
        exclude: [/elm-stuff/, /node_modules/],
        loaders: [
          'style-loader',
          'css-loader',
          {
            loader: 'postcss-loader',
            options: {
              plugins: () => [autoprefixer]
            }
          },
          'sass-loader'
        ]
      },
      {
        test: /\.css$/,
        exclude: [/elm-stuff/, /node_modules/],
        loaders: ['style-loader', 'css-loader']
      },
      {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: 'url-loader',
        options: {
          limit: 10000,
          mimetype: 'application/font-woff'
        }
      },
      {
        test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: 'file-loader'
      },
      {
        test: /\.(jpe?g|png|gif|svg)$/i,
        loader: 'file-loader'
      }
    ]
  }
}

const development = {
  plugins: [
    // Suggested for hot-loading
    new webpack.NamedModulesPlugin(),
    // Prevents compilation errors causing the hot loader to lose state
    new webpack.NoEmitOnErrorsPlugin()
  ],
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [
          {
            loader: 'elm-hot-loader'
          },
          {
            loader: 'elm-webpack-loader',
            options: {
              debug: true,
              forceWatch: true
            }
          }
        ]
      }
    ]
  },
  serve: {
    inline: true,
    stats: 'errors-only',
    content: path.join(__dirname, 'src/assets'),
    historyApiFallback: true,
    port: 3000
  }
}

const production = {
  plugins: [
    new CleanWebpackPlugin(['dist'], {
      root: __dirname,
      exclude: [],
      verbose: true,
      dry: false
    }),
    new CopyWebpackPlugin([
      {
        from: 'src/assets'
      }
    ]),
    new MiniCssExtractPlugin({
      filename: '[name]-[hash].css'
    })
  ],
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [
          {
            loader: 'elm-webpack-loader'
          }
        ]
      },
      {
        test: /\.css$/,
        exclude: [/elm-stuff/, /node_modules/],
        loaders: [MiniCssExtractPlugin.loader, 'css-loader']
      },
      {
        test: /\.scss$/,
        exclude: [/elm-stuff/, /node_modules/],
        loaders: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          {
            loader: 'postcss-loader',
            options: {
              plugins: () => [autoprefixer]
            }
          },
          'sass-loader'
        ]
      }
    ]
  }
}

console.log(`Building for ${MODE}..`)
module.exports = merge(common, MODE === 'production' ? production : development)
