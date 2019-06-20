// WARNING: Do not manually modify this file. It was generated using:
// https://github.com/dillonkearns/elm-typescript-interop
// Type definitions for Elm ports

export namespace Elm {
  namespace Main {
    export interface App {
      ports: {
        storeCurrency: {
          subscribe(callback: (data: string) => void): void
        }
        storeExpenses: {
          subscribe(callback: (data: string) => void): void
        }
        storeExchange: {
          subscribe(callback: (data: string) => void): void
        }
        storeActiveCurrencies: {
          subscribe(callback: (data: string) => void): void
        }
        updateLocation: {
          send(data: { accuracy: number; latitude: number; longitude: number }): void
        }
      };
    }
    export function init(options: {
      node?: HTMLElement | null;
      flags: { seed: number; currency: string | null; activeCurrencies: string | null; exchange: string | null; expenses: string | null };
    }): Elm.Main.App;
  }
}