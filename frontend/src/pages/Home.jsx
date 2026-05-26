import { Link } from "react-router-dom";
import { Globe, Award, Handshake } from "lucide-react";
import {
  digititanHomeHero,
  digititanStats,
  digititanServices,
  digititanRegistration,
} from "../data/digititanAbout";

const serviceIcons = [Globe, Award, Handshake];
const HERO_IMAGE = "/IMG.jpeg";

export default function Home() {
  return (
    <div className="relative min-h-screen bg-gradient-to-br from-blue-950 via-indigo-900 to-cyan-900 text-white overflow-hidden">
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute w-96 h-96 bg-cyan-500 rounded-full blur-[150px] opacity-20 top-10 left-10 animate-pulse" />
        <div className="absolute w-96 h-96 bg-purple-500 rounded-full blur-[150px] opacity-20 bottom-10 right-10 animate-pulse" />
      </div>

      {/* Hero — split layout (Digititan-style) */}
      <section className="relative z-10 max-w-7xl mx-auto px-6 sm:px-10 lg:px-12 py-16 md:py-24">
        <div className="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
          <div className="order-2 lg:order-1">
            <p className="inline-block px-4 py-2 bg-cyan-500/20 rounded-full border border-cyan-400/60 mb-6 text-sm font-medium">
              {digititanHomeHero.label}
            </p>

            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold leading-tight">
              {digititanHomeHero.title}{" "}
              <span className="block bg-gradient-to-r from-cyan-300 to-blue-400 bg-clip-text text-transparent">
                {digititanHomeHero.titleHighlight}
              </span>
            </h1>

            <p className="mt-6 text-gray-300 text-lg leading-relaxed max-w-xl">
              {digititanHomeHero.subtitle}
            </p>

            <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mt-10">
              {digititanStats.map((s, i) => (
                <div
                  key={i}
                  className="bg-white/10 backdrop-blur-md border border-white/10 rounded-2xl p-4 text-center hover:border-cyan-400/40 transition-colors"
                >
                  <p className="text-2xl sm:text-3xl font-black text-cyan-300">{s.value}</p>
                  <p className="text-xs sm:text-sm text-gray-400 mt-1">{s.label}</p>
                </div>
              ))}
            </div>

            <div className="flex flex-wrap gap-4 mt-10">
              <Link
                to="/about"
                className="bg-cyan-500 px-8 py-3.5 rounded-full font-semibold hover:scale-105 transition shadow-lg shadow-cyan-500/25"
              >
                Explore Programs
              </Link>
              <Link
                to="/donation"
                className="border border-cyan-400 px-8 py-3.5 rounded-full font-semibold hover:bg-cyan-500/20 transition"
              >
                Donate
              </Link>
              <Link to="/shop" className="border border-white/30 px-8 py-3.5 rounded-full font-semibold hover:bg-white/10 transition">
                Shop
              </Link>
            </div>
          </div>

          <div className="order-1 lg:order-2 flex justify-center lg:justify-end">
            <div className="relative w-full max-w-lg">
              <div className="absolute -inset-4 bg-gradient-to-tr from-cyan-500/30 to-purple-500/30 rounded-[2rem] blur-2xl" />
              <div className="relative overflow-hidden rounded-[2rem] border border-white/20 bg-white/5 backdrop-blur-sm shadow-2xl">
                <img
                  src={HERO_IMAGE}
                  alt="Village Netacad — digital skills and community learning"
                  className="w-full aspect-[4/5] sm:aspect-[3/4] object-cover"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-blue-950/80 via-transparent to-transparent pointer-events-none" />
                <div className="absolute bottom-0 left-0 right-0 p-6">
                  <p className="text-sm font-semibold text-cyan-300">Village Netacad</p>
                  <p className="text-xs text-gray-300 mt-1">Powered by Digititan</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Services — Digititan-style cards */}
      <section className="relative z-10 py-16 md:py-24 px-6 sm:px-10 lg:px-12 border-t border-white/10">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-12">
            <h2 className="text-3xl md:text-4xl font-bold mb-3">What We Do</h2>
            <p className="text-gray-400 max-w-2xl mx-auto">
              Building capacity through strategic partnerships and programmes at scale.
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            {digititanServices.map((item, i) => {
              const Icon = serviceIcons[i];
              return (
                <div
                  key={i}
                  className="bg-white/10 p-8 rounded-3xl border border-white/10 hover:-translate-y-2 transition hover:border-cyan-400/50 hover:shadow-[0_0_40px_rgba(34,211,238,0.15)]"
                >
                  <div className="w-14 h-14 rounded-2xl bg-cyan-500/20 flex items-center justify-center mb-5">
                    <Icon size={28} className="text-cyan-400" />
                  </div>
                  <h3 className="text-xl font-bold mb-3">{item.title}</h3>
                  <p className="text-gray-300 leading-relaxed">{item.desc}</p>
                </div>
              );
            })}
          </div>

          <div className="flex flex-wrap justify-center gap-4 mt-12">
            <a
              href={digititanRegistration.asc.url}
              target="_blank"
              rel="noopener noreferrer"
              className="bg-cyan-500 px-8 py-3 rounded-full font-semibold hover:scale-105 transition"
            >
              ASC Registration
            </a>
            <Link to="/register" className="border border-cyan-400 px-8 py-3 rounded-full font-semibold hover:bg-cyan-500/20 transition">
              Join Now
            </Link>
            <Link to="/contact" className="border border-white/30 px-8 py-3 rounded-full font-semibold hover:bg-white/10 transition">
              Contact Us
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}
