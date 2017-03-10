//GULP STARTER (modified from @dope's project of the same name)
const fs = require('fs');
const fileExists = require('file-exists');
const path = require('path');
const gulp = require('gulp');
const babel = require('gulp-babel');
const concat = require('gulp-concat');
const imagefull = 1200;
const imagehalf = 600;
const imagemin = require("gulp-imagemin");
const imageresize = require('gulp-image-resize');
const imagethumb = 80;
const os = require("os");
const parallel = require("concurrent-transform");
const plumber = require('gulp-plumber');
const pngquant = require('imagemin-pngquant');
const prefix = require('gulp-autoprefixer');
const pump = require('pump');
const rename = require("gulp-rename");
const sass = require('gulp-sass');
const sassfiles = ["./scss/**/*.scss"];
const sourcemaps = require('gulp-sourcemaps');
const uglify = require('gulp-uglify');
const cp = require('child_process');
const hugo_themes_dir = path.dirname(path.dirname(__dirname));
const hugo_themes_dirname = path.basename(hugo_themes_dir);
const hugo_dir = path.dirname(hugo_themes_dir);

var server = require('gulp-server-livereload');
var doc_root = hugo_dir + '/public';
var isDocker = false;
try {
    var fileContent = fs.readFileSync("/proc/1/cgroup", 'utf8');
} catch(err)  {
    var fileContent = '';
}
var isDocker = fileContent.match(/docker/);
if (isDocker) console.log('Running from inside docker');
var host = isDocker ? '0.0.0.0': '127.0.0.1';

/**
 *
 * Default task
 * - Runs sass, scripts, and image tasks
 * - Runs If from within a hugo dir: hugo, hugo_site_images
 * - Watchs for file changes for images, scripts and sass/css
 *
 **/
var tasks = ['scss', 'scripts', 'image-resize'];
var hugo_tasks = ['hugo'];

var within_hugo = false;
if (hugo_themes_dirname == 'themes') {
    var within_hugo = true;
}

/**
 *
 * Styles
 * - Compile
 * - Compress/Minify
 * - Catch errors (gulp-plumber)
 * - Autoprefixer
 *
 **/
gulp.task('scss', function() {
  gulp.src(sassfiles)
    .pipe(sass({ outputStyle: 'compressed' }).on('error', sass.logError))
    .pipe(prefix('last 2 versions', '> 1%', 'ie 10', 'Android 2', 'Firefox ESR'))
    .pipe(plumber())
    .pipe(rename('style.min.css'))
    .pipe(gulp.dest('../static/css'));
});

gulp.task("image-resize", () => {
  return gulp.src("../source-images/*.{jpg,png,jpeg,gif}")
    .pipe(imagemin())
    .pipe(parallel(
      imageresize({ width: imagefull }),
      os.cpus().length
    ))
    .pipe(gulp.dest("../static/images"))
    .pipe(parallel(
      imageresize({ width: imagehalf }),
      os.cpus().length
    ))
    .pipe(gulp.dest("../static/images/half"))
    .pipe(parallel(
      imageresize({ width: imagethumb }),
      os.cpus().length
    ))
    .pipe(gulp.dest("../static/images/thumb"));
});

/**Javascript **/
gulp.task('scripts', function(cb) {
  pump([
      gulp.src([
          'js/_clipboard.js',
          'js/_filesaver.js',
          'js/_velocity.min.js',
          'js/_velocity.ui.min.js',
          'js/_blast.js',
          'js/scripts/*.js']),
      babel({presets: ['es2015']}),
      concat('script.min.js'),
      uglify(),
      gulp.dest('../static/js/')
   ],
   cb
 );
});

/**Hugo **/
function shellexec(cmd, options) {
    return cp.exec(cmd, options, (error, stdout, stderr) => {
        if (stdout) console.log(stdout);
        if (stderr) console.log(stderr);
        if (error) {
            console.log('Final exit code is', error.code);
            console.log('!!! FIX YOUR HUGO CODE !!!');
            throw error;
        }
    });
}

var hugo_build = function() {
    shellexec('hugo', {'cwd': hugo_dir});
    gulp.src(doc_root+"/json.html")
        .pipe(rename('site-index.json'))
        .pipe(gulp.dest(doc_root));
    gulp.src(doc_root+"/json/index.html")
        .pipe(rename('site-index.json'))
        .pipe(gulp.dest(doc_root));
};
if (within_hugo) {
    console.log('Build hugo', hugo_dir);
    gulp.task("hugo", hugo_build);
    Array.prototype.push.apply(tasks, hugo_tasks);
}
var watcher = function() {
	gulp.watch('scss/**/*.scss', ['scss']);
	gulp.watch('js/**/*.js', ['scripts']);
    gulp.watch('../source-images/*',
               ['image-resize', hugo_tasks]);
    if (within_hugo) {
 		gulp.watch('../content/**/*', hugo_tasks);
		gulp.watch('../data/**/*', hugo_tasks);
		gulp.watch('../i18n/**/*', hugo_tasks);
		gulp.watch('../layouts/**/*', hugo_tasks);
		gulp.watch('../static/**/*', hugo_tasks);
        gulp.watch(hugo_dir+'/config.{yaml,toml}', hugo_tasks);
		gulp.watch(hugo_dir+'/content/**/*', hugo_tasks);
		gulp.watch(hugo_dir+'/data/**/*', hugo_tasks);
		gulp.watch(hugo_dir+'/i18n/**/*', hugo_tasks);
		gulp.watch(hugo_dir+'/layouts/**/*', hugo_tasks);
		gulp.watch(hugo_dir+'/static/**/*', hugo_tasks);
	}
};

/**Pipeline **/
gulp.task('default', tasks);
gulp.task('watch', ['default'], watcher);
if(within_hugo) {
    gulp.task('serve', ['watch'], function(cb) {
        console.log(hugo_dir+'/public');
        return gulp.src(doc_root)
            .pipe(server({
                livereload: true,
                directoryListing: {
                    enable: false,
                    path: doc_root,
                    options: undefined
                },
                host: host,
                open: false,
                port: 1313,
            }));
    });
}
